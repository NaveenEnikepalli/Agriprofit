const mongoose = require("mongoose");

const priceSchema = new mongoose.Schema({
  state: String,
  district: String,
  market: String,
  commodity: String,
  min_price: Number,
  max_price: Number,
  modal_price: Number,
  date: String
});

priceSchema.index({ state: 1, district: 1, market: 1, commodity: 1, date: 1 }, { unique: true });

module.exports = mongoose.model("Price", priceSchema);
