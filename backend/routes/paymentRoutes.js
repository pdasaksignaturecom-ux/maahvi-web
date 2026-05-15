const express = require('express');
const router = express.Router();
const { activateFreeVip, checkVipStatus } = require('../controllers/paymentController');

// VIP Activate Route
router.post('/activate-free', activateFreeVip);

// Check VIP Status Route
router.get('/status/:userId', checkVipStatus);

module.exports = router;