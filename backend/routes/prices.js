const express = require("express");
const axios = require("axios");
const Price = require("../models/Price");
const router = express.Router();

// Save prices from API to MongoDB
router.get("/fetch", async (req, res) => {
  try {
    if (!process.env.DATA_GOV_API_KEY) {
      return res.status(400).json({ error: "DATA_GOV_API_KEY is not configured on the server" });
    }
    const { state = "Andhra Pradesh", district, market, commodity = "Tomato" } = req.query;

    let url = `https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=${process.env.DATA_GOV_API_KEY}&format=json&limit=100&filters[state]=${encodeURIComponent(state)}&filters[commodity]=${encodeURIComponent(commodity)}`;
    if (district) url += `&filters[district]=${encodeURIComponent(district)}`;
    if (market) url += `&filters[market]=${encodeURIComponent(market)}`;

    const response = await axios.get(url);
    const records = response.data.records;

    const fetchedPrices = [];

    for (const rec of records) {
      // some records might be missing prices or arrival_date — skip those
      if (!rec.arrival_date) continue;

      const priceData = {
        state: rec.state,
        district: rec.district,
        market: rec.market,
        commodity: rec.commodity,
        min_price: rec.min_price ? rec.min_price / 100 : null,  // convert ₹/quintal → ₹/kg
        max_price: rec.max_price ? rec.max_price / 100 : null,
        modal_price: rec.modal_price ? rec.modal_price / 100 : null,
        date: rec.arrival_date
      };

      fetchedPrices.push(priceData);

      // continue saving to DB as before, but don't block on every upsert — run sequentially for simplicity
      await Price.updateOne(
        { state: priceData.state, district: priceData.district, market: priceData.market, commodity: priceData.commodity, date: priceData.date },
        { $set: priceData },
        { upsert: true }
      );
    }

    // Return the fetched prices in the response so the client sees the API data immediately
    res.json({ message: "✅ Prices fetched and saved to MongoDB", count: fetchedPrices.length, prices: fetchedPrices });
  } catch (err) {
    console.error("Error fetching prices:", err?.response?.data || err.message);
    res.status(500).json({ error: err?.response?.data?.message || "Failed to fetch prices" });
  }
});

// Get prices for a crop
router.get("/", async (req, res) => {
  try {
    const { state, district, market, commodity } = req.query;

    const query = {};
    if (state) query.state = state;
    if (district) query.district = district;
    if (market) query.market = market;
    if (commodity) query.commodity = commodity;

    const prices = await Price.find(query).sort({ date: -1 }).limit(50);
    res.json(prices);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch from DB" });
  }
});

module.exports = router;
