require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const pricesRoute = require("./routes/prices");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/prices", pricesRoute);

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB Connected"))
  .catch(err => console.error("❌ MongoDB Error:", err));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
