const mongoose = require('mongoose');
const State = require('./models/State');
const User = require('./models/User');
const Result = require('./models/Result');
const Prediction = require('./models/Prediction');

const MONGO_URI = 'mongodb://127.0.0.1:27017/maahvi';

const seedData = async () => {
  try {
    await mongoose.connect(MONGO_URI);
    console.log("Connected! Resetting Database with Sample Data...");

    // ক্লিয়ার করা
    await State.deleteMany();
    await User.deleteMany();
    await Result.deleteMany();
    await Prediction.deleteMany();

    // ১. স্টেট তৈরি
    const state = new State({ 
      name: 'West Bengal', 
      code: 'west-bengal', 
      image: 'https://cdn-icons-png.flaticon.com/512/295/295240.png' 
    });
    await state.save();
    console.log("✅ West Bengal State Added.");

    // ২. আজকের তারিখ (DD-MM-YYYY ফরম্যাট)
    const today = new Date();
    const dd = String(today.getDate()).padStart(2, '0');
    const mm = String(today.getMonth() + 1).padStart(2, '0');
    const yyyy = today.getFullYear();
    const todayStr = `${dd}-${mm}-${yyyy}`;

    // ৩. স্যাম্পল রেজাল্ট তৈরি (1PM, 6PM, 8PM)
    const sampleResults = [
      {
        stateId: state._id,
        date: todayStr,
        drawTime: "1 PM",
        drawName: "DEAR MORNING",
        winningNumbers: ["12A 45678"],
        imageUrl: "https://via.placeholder.com/400x600?text=Dear+1PM+Result",
        pdfUrl: "https://www.wblotteries.gov.in/results/1PM.pdf"
      },
      {
        stateId: state._id,
        date: todayStr,
        drawTime: "6 PM",
        drawName: "DEAR DAY",
        winningNumbers: ["89B 12345"],
        imageUrl: "https://via.placeholder.com/400x600?text=Dear+6PM+Result",
        pdfUrl: "https://www.wblotteries.gov.in/results/6PM.pdf"
      },
      {
        stateId: state._id,
        date: todayStr,
        drawTime: "8 PM",
        drawName: "DEAR NIGHT",
        winningNumbers: ["55C 98765"],
        imageUrl: "https://via.placeholder.com/400x600?text=Dear+8PM+Result",
        pdfUrl: "https://www.wblotteries.gov.in/results/8PM.pdf"
      }
    ];
    await Result.insertMany(sampleResults);
    console.log("✅ Sample Results Added for Today.");

    // ৪. স্যাম্পল প্রেডিকশন (এখানে date যোগ করা হয়েছে)
    const prediction = new Prediction({
      stateId: state._id,
      date: todayStr, // তারিখ যোগ করা হলো
      predictionNumbers: ["4521", "8892", "1023", "7745"],
      analysis: "Based on previous 7 days patterns, these middle-part numbers have high winning probability for today's draw."
    });
    await prediction.save();
    console.log("✅ Sample Prediction Added.");

    console.log("\n🚀 Database is now ready! Refresh your app.");
    process.exit();
  } catch (error) {
    console.error("❌ Seeding Error:", error.message);
    process.exit(1);
  }
};

seedData();
