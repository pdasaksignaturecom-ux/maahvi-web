const State = require('../models/State');

// @desc    Get all states
// @route   GET /api/states
exports.getStates = async (req, res) => {
  try {
    const states = await State.find();
    res.status(200).json(states);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a new state
// @route   POST /api/states
exports.createState = async (req, res) => {
  const { name, code, image } = req.body;
  try {
    const newState = new State({ name, code, image });
    await newState.save();
    res.status(201).json(newState);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
