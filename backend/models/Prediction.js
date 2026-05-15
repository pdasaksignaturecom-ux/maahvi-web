const mongoose = require('mongoose');

const predictionSchema = mongoose.Schema({
  stateId: { type: mongoose.Schema.Types.ObjectId, ref: 'State', required: true },
  date: { type: String, required: true },
  drawTime: { type: String }, 
  predictionNumbers: [String],
  analysis: { type: String }, // Optional: logic behind prediction
  isVip: { type: Boolean, default: false } // For VIP users
}, { timestamps: true });

module.exports = mongoose.model('Prediction', predictionSchema);
