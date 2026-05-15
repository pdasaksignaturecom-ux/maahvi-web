const Result = require('../models/Result');
const State = require('../models/State');
const mongoose = require('mongoose');

// আজকের তারিখ পাওয়ার ফাংশন (DD-MM-YYYY)
const getTodayDate = () => {
  const today = new Date();
  const dd = String(today.getDate()).padStart(2, '0');
  const mm = String(today.getMonth() + 1).padStart(2, '0');
  const yyyy = today.getFullYear();
  return `${dd}-${mm}-${yyyy}`;
};

// @desc    স্টেট অনুযায়ী রেজাল্ট পাওয়া
exports.getResultsByState = async (req, res) => {
  try {
    const { stateId } = req.params;
    let { date } = req.query;
    
    let state;
    if (mongoose.Types.ObjectId.isValid(stateId)) {
      state = await State.findById(stateId);
    } else {
      state = await State.findOne({ 
        $or: [{ code: stateId }, { name: stateId }] 
      });
    }

    if (!state) return res.status(404).json({ message: 'State not found' });

    let results;
    if (date) {
      // নির্দিষ্ট তারিখের রেজাল্ট (পুরানো রেজাল্ট দেখার জন্য)
      results = await Result.find({ stateId: state._id, date: date }).sort({ createdAt: 1 });
    } else {
      // তারিখ না থাকলে, ডাটাবেসে থাকা সর্বশেষ আপলোড করা তারিখের রেজাল্টগুলো দেখাবে।
      // এতে করে নতুন দিন শুরু হলেও আগের দিনের রেজাল্ট দেখা যাবে যতক্ষণ না নতুন রেজাল্ট আপলোড হয়।
      const lastResult = await Result.findOne({ stateId: state._id }).sort({ createdAt: -1 });
      if (lastResult) {
        // সর্বশেষ যে তারিখের রেজাল্ট আছে, সেই তারিখের সব স্লটের রেজাল্ট নিয়ে আসা
        results = await Result.find({ stateId: state._id, date: lastResult.date }).sort({ createdAt: 1 });
      } else {
        results = [];
      }
    }
    
    res.status(200).json(results);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    রেজাল্ট তৈরি বা আপডেট
exports.createResult = async (req, res) => {
  try {
    const { stateName, date, drawTime, drawName, winningNumbers, pdfUrl, imageUrl } = req.body;
    
    const state = await State.findOne({ 
      $or: [{ name: stateName }, { code: stateName }] 
    });
    
    if (!state) return res.status(404).json({ message: "State not found" });

    // একই তারিখ, স্টেট এবং ড্র টাইম থাকলে আপডেট হবে, নাহলে নতুন তৈরি হবে।
    // এটি নিশ্চিত করে যে ডাটাবেসে একই স্লটের ডুপ্লিকেট রেজাল্ট থাকবে না।
    const filter = { stateId: state._id, date, drawTime };
    const update = { drawName, winningNumbers, pdfUrl, imageUrl };

    const savedResult = await Result.findOneAndUpdate(
      filter, 
      update, 
      { new: true, upsert: true }
    );

    res.status(201).json(savedResult);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    রেজাল্ট ডিলিট করা
exports.deleteResult = async (req, res) => {
  try {
    const result = await Result.findByIdAndDelete(req.params.id);
    if (!result) return res.status(404).json({ message: 'Result not found' });
    res.status(200).json({ message: 'Result deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    লেটেস্ট একটি রেজাল্ট পাওয়া
exports.getLatestResult = async (req, res) => {
  try {
    const { stateId } = req.params;
    let state = await State.findOne({ $or: [{ code: stateId }, { name: stateId }] });
    if (!state) return res.status(404).json({ message: 'State not found' });

    const result = await Result.findOne({ stateId: state._id }).sort({ createdAt: -1 });
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    আইডি অনুযায়ী রেজাল্ট পাওয়া
exports.getResultById = async (req, res) => {
  try {
    const result = await Result.findById(req.params.id);
    if (!result) return res.status(404).json({ message: 'Result not found' });
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    রেজাল্ট PDF ডাউনলোড করা
exports.downloadResultPDF = async (req, res) => {
  try {
    const result = await Result.findById(req.params.id);
    if (!result || !result.pdfUrl) {
      return res.status(404).json({ message: 'PDF not found' });
    }
    // সরাসরি PDF URL-এ রিডাইরেক্ট করা
    res.redirect(result.pdfUrl);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
