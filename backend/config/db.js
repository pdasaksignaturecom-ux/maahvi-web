const mongoose = require('mongoose');

const connectDB = async () => {
  const MONGO_URI = 'mongodb://127.0.0.1:27017/maahvi';
  let retries = 5;

  while (retries > 0) {
    try {
      console.log(`Attempting to connect to Local MongoDB... (${retries} attempts left)`);
      await mongoose.connect(MONGO_URI);
      console.log(`✅ MongoDB Connected Successfully!`);
      return; 
    } catch (err) {
      retries -= 1;
      console.error(`❌ MongoDB Connection Error: ${err.message}`);
      
      if (retries === 0) {
        console.warn("⚠️ Could not connect to MongoDB, but keeping the server alive for testing.");
        // process.exit(1); // আমরা এটি বন্ধ করে দিচ্ছি যাতে সার্ভার ক্র্যাশ না করে
        return;
      }
      
      console.log("Retrying in 2 seconds...");
      await new Promise(res => setTimeout(res, 2000));
    }
  }
};

module.exports = connectDB;
