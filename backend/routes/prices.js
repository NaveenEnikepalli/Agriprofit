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
    
    // Get user inputs from query parameters
    const { state, district, market, commodity } = req.query;
    
    // Validate required parameters
    if (!state) {
      return res.status(400).json({ error: "State parameter is required" });
    }
    if (!commodity) {
      return res.status(400).json({ error: "Commodity parameter is required" });
    }

    let url = `https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=${process.env.DATA_GOV_API_KEY}&format=json&limit=1000&filters[state]=${encodeURIComponent(state)}&filters[commodity]=${encodeURIComponent(commodity)}`;
    if (district) url += `&filters[district]=${encodeURIComponent(district)}`;
    if (market) url += `&filters[market]=${encodeURIComponent(market)}`;

    // Configure axios with timeout and retry logic
    const axiosConfig = {
      timeout: 60000, // 60 seconds timeout (increased from 30)
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0'
      },
      validateStatus: function (status) {
        return status < 500; // Don't throw for 4xx errors
      }
    };

    let response;
    let apiError = null;
    
    // Try to fetch from API with retry logic
    const maxRetries = 2; // Reduced retries but with longer timeout
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        console.log(`Attempting to fetch from API (attempt ${attempt}/${maxRetries}) for ${commodity} in ${state}...`);
        response = await axios.get(url, axiosConfig);
        
        // Check if response is successful
        if (response.status >= 200 && response.status < 300) {
          apiError = null;
          break; // Success, exit retry loop
        } else {
          // HTTP error but not network error
          apiError = new Error(`API returned status ${response.status}`);
          break;
        }
      } catch (err) {
        apiError = err;
        const isTimeout = err.code === 'ETIMEDOUT' || err.code === 'ECONNABORTED' || err.message?.includes('timeout');
        const isConnectionError = err.code === 'ECONNREFUSED' || err.code === 'ENOTFOUND' || err.code === 'ETIMEDOUT' || err.code === 'ECONNRESET';
        
        console.error(`API request failed (attempt ${attempt}/${maxRetries}):`, err.message || err.code);
        
        if (attempt < maxRetries && (isTimeout || isConnectionError)) {
          // Wait before retrying (exponential backoff)
          const waitTime = attempt * 3000; // 3s, 6s
          console.log(`Retrying in ${waitTime}ms...`);
          await new Promise(resolve => setTimeout(resolve, waitTime));
          continue;
        } else {
          // All retries failed or non-retryable error
          break;
        }
      }
    }

    // Helper function to escape regex special characters
    const escapeRegex = (str) => {
      return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    };

    // Helper function to search database with case-insensitive matching
    const searchDatabase = async (searchState, searchDistrict, searchMarket, searchCommodity) => {
      const query = {};
      if (searchState) {
        query.state = new RegExp(`^${escapeRegex(searchState)}$`, 'i');
      }
      if (searchDistrict) {
        query.district = new RegExp(`^${escapeRegex(searchDistrict)}$`, 'i');
      } else if (searchDistrict === '') {
        query.district = '';
      }
      if (searchMarket) {
        query.market = new RegExp(`^${escapeRegex(searchMarket)}$`, 'i');
      } else if (searchMarket === '') {
        query.market = '';
      }
      if (searchCommodity) {
        query.commodity = new RegExp(`^${escapeRegex(searchCommodity)}$`, 'i');
      }
      return await Price.find(query).sort({ date: -1 }).limit(100);
    };

    // If API call failed, try to return data from database as fallback
    if (apiError || !response) {
      console.log("API call failed, attempting to fetch from database as fallback...");
      
      try {
        // Try exact match first
        let dbPrices = await searchDatabase(state, district || '', market || '', commodity);
        
        // If no results, try case-insensitive commodity search with variations
        if (dbPrices.length === 0) {
          console.log("No exact match found, trying case-insensitive search...");
          // Try with different commodity name variations
          const commodityVariations = [
            commodity,
            commodity.toLowerCase(),
            commodity.toUpperCase(),
            commodity.charAt(0).toUpperCase() + commodity.slice(1).toLowerCase(),
            commodity.replace(/\s+/g, ' ').trim()
          ];
          
          for (const variation of commodityVariations) {
            if (variation === commodity) continue; // Already tried
            dbPrices = await searchDatabase(state, district || '', market || '', variation);
            if (dbPrices.length > 0) {
              console.log(`Found prices with commodity variation: ${variation}`);
              break;
            }
          }
        }
        
        if (dbPrices.length > 0) {
          const latestDate = dbPrices[0].date;
          const latestPrices = dbPrices.filter(p => p.date === latestDate);
          
          return res.json({
            message: "⚠️ API unavailable, returning cached data from database",
            warning: "Unable to fetch latest data from API. Showing cached prices.",
            source: "database",
            count: dbPrices.length,
            latestDate: latestDate,
            latestCount: latestPrices.length,
            prices: dbPrices,
            latestPrices: latestPrices,
            apiError: apiError?.message || "Connection timeout"
          });
        } else {
          // No data in database either
          return res.status(503).json({
            error: "API is currently unavailable and no cached data found",
            message: `No prices found for ${commodity} in ${state}. Please try again later or check if the commodity name is correct.`,
            apiError: apiError?.message || apiError?.code || "Connection timeout",
            source: "none",
            prices: []
          });
        }
      } catch (dbErr) {
        console.error("Database fallback also failed:", dbErr);
        return res.status(503).json({
          error: "Service temporarily unavailable",
          message: "Both API and database queries failed. Please try again later.",
          apiError: apiError?.message || apiError?.code || "Connection timeout",
          dbError: dbErr.message,
          prices: []
        });
      }
    }
    
    // Check if response data exists and has records
    if (!response.data) {
      return res.status(500).json({ error: "Invalid API response: no data received" });
    }

    // Handle different possible response structures
    const records = response.data.records || response.data.data || [];
    
    if (!Array.isArray(records)) {
      return res.status(500).json({ error: "Invalid API response: records is not an array" });
    }

    if (records.length === 0) {
      // API returned successfully but no records - try database fallback
      console.log("API returned empty results, trying database fallback...");
      
      try {
        const query = {};
        if (state) query.state = new RegExp(`^${escapeRegex(state)}$`, 'i');
        if (district) query.district = new RegExp(`^${escapeRegex(district)}$`, 'i');
        else if (district === '') query.district = '';
        if (market) query.market = new RegExp(`^${escapeRegex(market)}$`, 'i');
        else if (market === '') query.market = '';
        if (commodity) query.commodity = new RegExp(`^${escapeRegex(commodity)}$`, 'i');

        let dbPrices = await Price.find(query).sort({ date: -1 }).limit(100);
        
        // Try commodity variations if no results
        if (dbPrices.length === 0) {
          const commodityVariations = [
            commodity.toLowerCase(),
            commodity.toUpperCase(),
            commodity.charAt(0).toUpperCase() + commodity.slice(1).toLowerCase()
          ];
          
          for (const variation of commodityVariations) {
            query.commodity = new RegExp(`^${escapeRegex(variation)}$`, 'i');
            dbPrices = await Price.find(query).sort({ date: -1 }).limit(100);
            if (dbPrices.length > 0) break;
          }
        }
        
        if (dbPrices.length > 0) {
          const latestDate = dbPrices[0].date;
          const latestPrices = dbPrices.filter(p => p.date === latestDate);
          
          return res.json({
            message: "⚠️ No current API data, returning cached data from database",
            warning: "API returned no results. Showing cached prices from database.",
            source: "database",
            count: dbPrices.length,
            latestDate: latestDate,
            latestCount: latestPrices.length,
            prices: dbPrices,
            latestPrices: latestPrices
          });
        }
      } catch (dbErr) {
        console.error("Database fallback failed:", dbErr);
      }
      
      // No data in API or database
      return res.status(404).json({ 
        error: `No prices found for state: ${state}, commodity: ${commodity}${district ? `, district: ${district}` : ''}${market ? `, market: ${market}` : ''}`,
        message: `The API has no data for ${commodity} in ${state}. Please check the commodity name spelling or try a different commodity.`,
        prices: []
      });
    }

    const fetchedPrices = [];
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    for (const rec of records) {
      // Skip records missing arrival_date
      if (!rec.arrival_date) continue;

      // Parse and validate date
      let dateStr = rec.arrival_date;
      // Handle different date formats
      if (dateStr.includes('/')) {
        // Format: DD/MM/YYYY
        const [day, month, year] = dateStr.split('/');
        dateStr = `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
      }

      const priceData = {
        state: rec.state || state,
        district: rec.district || district || null,
        market: rec.market || market || null,
        commodity: rec.commodity || commodity,
        min_price: rec.min_price ? parseFloat(rec.min_price) / 100 : null,  // convert ₹/quintal → ₹/kg
        max_price: rec.max_price ? parseFloat(rec.max_price) / 100 : null,
        modal_price: rec.modal_price ? parseFloat(rec.modal_price) / 100 : null,
        date: dateStr
      };

      fetchedPrices.push(priceData);

      // Save to DB
      try {
        await Price.updateOne(
          { 
            state: priceData.state, 
            district: priceData.district || '', 
            market: priceData.market || '', 
            commodity: priceData.commodity, 
            date: priceData.date 
          },
          { $set: priceData },
          { upsert: true }
        );
      } catch (dbErr) {
        console.error("Error saving to DB:", dbErr);
        // Continue processing other records even if one fails
      }
    }

    // Sort by date (latest first)
    fetchedPrices.sort((a, b) => {
      const dateA = new Date(a.date);
      const dateB = new Date(b.date);
      return dateB - dateA;
    });

    // Get latest prices (today's or most recent)
    const latestDate = fetchedPrices.length > 0 ? fetchedPrices[0].date : null;
    const latestPrices = fetchedPrices.filter(p => p.date === latestDate);

    // Return the fetched prices with latest prices highlighted
    res.json({ 
      message: "✅ Prices fetched and saved to MongoDB", 
      source: "api",
      count: fetchedPrices.length,
      latestDate: latestDate,
      latestCount: latestPrices.length,
      prices: fetchedPrices,
      latestPrices: latestPrices
    });
  } catch (err) {
    // This catch block handles unexpected errors during processing
    console.error("Unexpected error during price processing:", err?.response?.data || err.message);
    
    // If it's a network/API error that wasn't caught earlier, try database fallback
    const isNetworkError = err.code === 'ETIMEDOUT' || err.code === 'ECONNABORTED' || 
                          err.code === 'ECONNREFUSED' || err.code === 'ENOTFOUND' ||
                          err.message?.includes('timeout') || err.message?.includes('ECONNREFUSED');
    
    if (isNetworkError) {
      const { state, district, market, commodity } = req.query;
      const query = {};
      if (state) query.state = state;
      if (district) query.district = district || '';
      if (market) query.market = market || '';
      if (commodity) query.commodity = commodity;

      try {
        const dbPrices = await Price.find(query).sort({ date: -1 }).limit(100);
        if (dbPrices.length > 0) {
          const latestDate = dbPrices[0].date;
          const latestPrices = dbPrices.filter(p => p.date === latestDate);
          
          return res.json({
            message: "⚠️ API unavailable, returning cached data from database",
            warning: "Unable to fetch latest data from API. Showing cached prices.",
            source: "database",
            count: dbPrices.length,
            latestDate: latestDate,
            latestCount: latestPrices.length,
            prices: dbPrices,
            latestPrices: latestPrices,
            apiError: err.message || "Connection error"
          });
        }
      } catch (dbErr) {
        console.error("Database fallback failed:", dbErr);
      }
    }
    
    // If fallback didn't work or it's a different error, return error response
    const errorMessage = err?.response?.data?.message || err?.response?.data?.error || err.message || "Failed to fetch prices";
    res.status(err?.response?.status || 500).json({ 
      error: errorMessage,
      details: err.code || "Unknown error"
    });
  }
});

// Get prices for a crop (with latest prices priority)
router.get("/", async (req, res) => {
  try {
    const { state, district, market, commodity, format } = req.query;

    // Helper function to escape regex special characters
    const escapeRegex = (str) => {
      return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    };

    // Use case-insensitive regex for better matching
    const query = {};
    if (state) query.state = new RegExp(`^${escapeRegex(state)}$`, 'i');
    if (district) query.district = new RegExp(`^${escapeRegex(district)}$`, 'i');
    else if (district === '') query.district = '';
    if (market) query.market = new RegExp(`^${escapeRegex(market)}$`, 'i');
    else if (market === '') query.market = '';
    if (commodity) query.commodity = new RegExp(`^${escapeRegex(commodity)}$`, 'i');

    // Fetch all matching prices sorted by date (latest first)
    let allPrices = await Price.find(query).sort({ date: -1 }).limit(1000);
    
    // If no results, try commodity name variations
    if (allPrices.length === 0 && commodity) {
      const commodityVariations = [
        commodity.toLowerCase(),
        commodity.toUpperCase(),
        commodity.charAt(0).toUpperCase() + commodity.slice(1).toLowerCase()
      ];
      
      for (const variation of commodityVariations) {
        query.commodity = new RegExp(`^${escapeRegex(variation)}$`, 'i');
        allPrices = await Price.find(query).sort({ date: -1 }).limit(1000);
        if (allPrices.length > 0) break;
      }
    }
    
    if (allPrices.length === 0) {
      // Return empty array for backward compatibility with frontend
      if (format === 'enhanced') {
        return res.json({
          message: "No prices found in database",
          prices: [],
          latestPrices: [],
          latestDate: null
        });
      }
      return res.json([]);
    }

    // Get the latest date (most recent)
    const latestDate = allPrices[0].date;
    const latestPrices = allPrices.filter(p => p.date === latestDate);

    // Find the previous latest date (second most recent) as fallback
    let previousLatestDate = null;
    let previousLatestPrices = [];
    
    for (const price of allPrices) {
      if (price.date !== latestDate) {
        previousLatestDate = price.date;
        break;
      }
    }
    
    if (previousLatestDate) {
      previousLatestPrices = allPrices.filter(p => p.date === previousLatestDate);
    }

    // Return latest prices, with previous latest as fallback option
    // If latestPrices is empty (shouldn't happen), use previousLatestPrices
    const pricesToReturn = latestPrices.length > 0 ? latestPrices : previousLatestPrices;

    // If format=enhanced is requested, return the full object with metadata
    if (format === 'enhanced') {
      return res.json({
        message: "Prices retrieved successfully",
        prices: allPrices,
        latestPrices: pricesToReturn,
        latestDate: latestPrices.length > 0 ? latestDate : previousLatestDate,
        previousLatestPrices: previousLatestPrices,
        previousLatestDate: previousLatestDate,
        count: allPrices.length,
        latestCount: pricesToReturn.length,
        hasLatestPrices: latestPrices.length > 0
      });
    }

    // Default: Return direct array for backward compatibility with frontend
    // Return latest prices first, or all prices if no latest available
    const pricesArray = pricesToReturn.length > 0 ? pricesToReturn : allPrices.slice(0, 50);
    res.json(pricesArray);
  } catch (err) {
    console.error("Error fetching prices from DB:", err);
    res.status(500).json({ error: "Failed to fetch from DB: " + err.message });
  }
});

module.exports = router;
