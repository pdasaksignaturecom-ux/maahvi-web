const Ad = require('../models/Ad');

// @desc    Get all active ads
// @route   GET /api/ads
exports.getAds = async (req, res) => {
  try {
    const ads = await Ad.find({ isActive: true });
    res.status(200).json(ads);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a new ad (Admin only)
// @route   POST /api/ads
exports.createAd = async (req, res) => {
  try {
    const newAd = new Ad(req.body);
    await newAd.save();
    res.status(201).json(newAd);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Update an ad
// @route   PUT /api/ads/:id
exports.updateAd = async (req, res) => {
  try {
    const updatedAd = await Ad.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.status(200).json(updatedAd);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Delete an ad
// @route   DELETE /api/ads/:id
exports.deleteAd = async (req, res) => {
  try {
    await Ad.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: "Ad deleted successfully" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
