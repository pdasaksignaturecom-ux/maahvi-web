const mongoose = require('mongoose');

const stateSchema = mongoose.Schema({
  name: { type: String, required: true },
  code: { type: String, required: true, unique: true }, // e.g., 'kerala', 'nagaland'
  image: { type: String }, // URL for state icon
}, { timestamps: true });

module.exports = mongoose.model('State', stateSchema);
