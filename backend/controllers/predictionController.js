const Prediction = require('../models/Prediction');
const State = require('../models/State');
const mongoose = require('mongoose');

const getTodayDate = () => {
  const today = new Date();
  const dd = String(today.getDate()).padStart(2, '0');
  const mm = String(today.getMonth() + 1).padStart(2, '0');
  const yyyy = today.getFullYear();
  return `${dd}-${mm}-${yyyy}`;
};

exports.createBulkPredictions = async (req, res) => {
  try {
    const { stateName, date, predictions } = req.body;
    
    const state = await State.findOne({ 
      $or: [
        { name: new RegExp('^' + stateName + '$', 'i') }, 
        { code: stateName.toLowerCase() }
      ] 
    });
    
    if (!state) return res.status(404).json({ message: "State not found" });

    const results = [];
    for (const pred of predictions) {
      const { drawTime, predictionNumbers, isVip } = pred;
      const isVipBool = isVip === true || isVip === 'true';
      
      const filter = { stateId: state._id, date, drawTime, isVip: isVipBool };
      const update = { predictionNumbers, isVip: isVipBool, analysis: "" };

      const saved = await Prediction.findOneAndUpdate(filter, update, { 
        new: true, 
        upsert: true, 
        setDefaultsOnInsert: true 
      });
      results.push(saved);
    }
    
    res.status(201).json({ message: "Bulk save successful", count: results.length });
  } catch (error) {
    console.error("Bulk save error:", error);
    res.status(500).json({ message: error.message });
  }
};

exports.getPredictionsByState = async (req, res) => {
  try {
    const { stateId } = req.params;
    const { date } = req.query;
    let state = mongoose.Types.ObjectId.isValid(stateId) 
        ? await State.findById(stateId) 
        : await State.findOne({ $or: [{ code: stateId }, { name: new RegExp('^' + stateId + '$', 'i') }] });
    
    if (!state) return res.status(200).json([]);
    const query = { stateId: state._id };
    if (date) query.date = date;
    const predictions = await Prediction.find(query).sort({ drawTime: 1, isVip: 1 });
    res.status(200).json(predictions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getLatestPrediction = async (req, res) => {
  try {
    const { stateId } = req.params;
    let state = mongoose.Types.ObjectId.isValid(stateId) 
        ? await State.findById(stateId) 
        : await State.findOne({ $or: [{ code: stateId }, { name: new RegExp('^' + stateId + '$', 'i') }] });
    
    if (!state) return res.status(404).json({ message: "State not found" });

    const prediction = await Prediction.findOne({ stateId: state._id })
      .sort({ createdAt: -1 });
    
    res.status(200).json(prediction || {});
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createPrediction = async (req, res) => {
  try {
    let { stateName, date, drawTime, predictionNumbers, isVip } = req.body;
    const state = await State.findOne({ $or: [{ name: new RegExp('^' + stateName + '$', 'i') }, { code: stateName.toLowerCase() }] });
    if (!state) return res.status(404).json({ message: "State not found" });
    const isVipBool = isVip === true || isVip === 'true';
    const filter = { stateId: state._id, date: date || getTodayDate(), drawTime, isVip: isVipBool };
    const saved = await Prediction.findOneAndUpdate(filter, { predictionNumbers, isVip: isVipBool }, { new: true, upsert: true });
    res.status(201).json(saved);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.deletePrediction = async (req, res) => {
  try {
    await Prediction.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
