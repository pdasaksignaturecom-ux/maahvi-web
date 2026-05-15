const mongoose = require('mongoose');

const SettingSchema = new mongoose.Schema({
  vipSecretCode: {
    type: String,
    default: "DEAR77"
  },
  taskUrl: {
    type: String,
    default: "https://t.me/yourchannel"
  },
  taskInstructions: {
    type: String,
    default: "Follow the link and find the secret activation code."
  }
}, { timestamps: true });

module.exports = mongoose.model('Setting', SettingSchema);
