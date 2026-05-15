const mongoose = require('mongoose');

const adSchema = mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  type: { type: String, enum: ['image', 'text', 'link', 'video'], required: true },
  mediaUrl: { type: String }, // For image or video URLs
  linkUrl: { type: String }, // For external redirect links
  isActive: { type: Boolean, default: true },
  position: { type: String, enum: ['home_top', 'home_middle', 'result_bottom'], default: 'home_middle' }
}, { timestamps: true });

module.exports = mongoose.model('Ad', adSchema);
