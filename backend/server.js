const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

const stateRoutes = require('./routes/stateRoutes');
const resultRoutes = require('./routes/resultRoutes');
const paymentRoutes = require('./routes/paymentRoutes');
const predictionRoutes = require('./routes/predictionRoutes');
const adRoutes = require('./routes/adRoutes');
const settingRoutes = require('./routes/settingRoutes');

const app = express();

// ১. ডাটাবেস কানেক্ট করা
connectDB();

// ২. উন্নত CORS সেটিংস - এটি ব্রাউজারের "Failed to fetch" এরর সমাধান করবে
app.use(cors({
  origin: function (origin, callback) {
    // এটি সব অরিজিন (localhost বা 127.0.0.1) থেকে রিকোয়েস্ট গ্রহণ করবে
    callback(null, true);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin', 'Access-Control-Allow-Private-Network']
}));

// ৩. Chrome Private Network Access এবং Preflight (OPTIONS) রিকোয়েস্ট হ্যান্ডলিং
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Private-Network", "true");
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

app.use(express.json());

// ৪. API রাউটস
app.use('/api/states', stateRoutes);
app.use('/api/results', resultRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/predictions', predictionRoutes);
app.use('/api/ads', adRoutes);
app.use('/api/settings', settingRoutes);

app.get('/', (req, res) => res.send("Maahvi Lottery Backend is Running"));

const PORT = 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server is live at http://localhost:${PORT}`);
});
