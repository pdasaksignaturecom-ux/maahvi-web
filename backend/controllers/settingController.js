const Setting = require('../models/Setting');

// @desc    Get current settings
// @route   GET /api/settings
exports.getSettings = async (req, res) => {
  try {
    let settings = await Setting.findOne();
    if (!settings) {
      settings = await Setting.create({});
    }
    res.status(200).json(settings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update settings
// @route   POST /api/settings
exports.updateSettings = async (req, res) => {
  const { vipSecretCode, taskUrl, taskInstructions } = req.body;
  try {
    let settings = await Setting.findOne();
    if (settings) {
      // Update fields if provided
      if (vipSecretCode !== undefined) settings.vipSecretCode = vipSecretCode;
      if (taskUrl !== undefined) settings.taskUrl = taskUrl;
      if (taskInstructions !== undefined) settings.taskInstructions = taskInstructions;
      await settings.save();
    } else {
      settings = await Setting.create({ vipSecretCode, taskUrl, taskInstructions });
    }
    res.status(200).json(settings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
