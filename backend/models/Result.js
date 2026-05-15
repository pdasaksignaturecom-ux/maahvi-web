const mongoose = require('mongoose');

const resultSchema = mongoose.Schema({
  stateId: { type: mongoose.Schema.Types.ObjectId, ref: 'State', required: true },
  date: { type: String, required: true }, // Format: YYYY-MM-DD
  drawTime: { type: String }, // e.g., '1 PM', '6 PM', '8 PM'
  drawName: { type: String }, // e.g., 'Singham Afternoon'
  winningNumbers: {
    firstPrize: [String],
    secondPrize: [String],
    thirdPrize: [String],
    fourthPrize: [String],
    fifthPrize: [String],
  },
  pdfUrl: { type: String },
  imageUrl: { type: String }, // For "Photo Mode" results
}, { timestamps: true });

module.exports = mongoose.model('Result', resultSchema);
