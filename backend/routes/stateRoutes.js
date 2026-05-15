const express = require('express');
const router = express.Router();
const { getStates, createState } = require('../controllers/stateController');

// সব স্টেট পাওয়া এবং নতুন স্টেট অ্যাড করা
router.route('/').get(getStates).post(createState);

module.exports = router;
