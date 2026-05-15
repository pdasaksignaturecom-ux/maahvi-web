const User = require('../models/User');
const Setting = require('../models/Setting');

// @desc    Activate Temporary VIP by Task Verification Code
// @route   POST /api/payments/activate-free
exports.activateFreeVip = async (req, res) => {
  const { userId, taskCode } = req.body;
  
  try {
    const settings = await Setting.findOne();
    const DB_CODE = settings ? settings.vipSecretCode : "DEAR77";

    // Case-insensitive and Trimmed check
    if (!taskCode || taskCode.trim().toUpperCase() !== DB_CODE.trim().toUpperCase()) {
      return res.status(400).json({ 
        message: "ভুল ভেরিফিকেশন কোড! সঠিক কোডটি টাস্ক পেজ থেকে সংগ্রহ করুন।" 
      });
    }

    // Attempt to update user if a valid ID is provided
    if (userId && userId.length === 24) {
      try {
        const user = await User.findById(userId);
        if (user) {
          user.isVip = true;
          user.subscriptionExpiresAt = new Date(Date.now() + 12 * 60 * 60 * 1000);
          await user.save();
        }
      } catch (err) {
        console.log("User update skipped: " + err.message);
      }
    }

    // Always return success if code is correct
    res.status(200).json({ 
      message: "Verification Successful! VIP Access granted.",
      isVip: true
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.checkVipStatus = async (req, res) => {
  const { userId } = req.params;
  try {
    if (!userId || userId.length !== 24) return res.status(200).json({ isVip: false });
    const user = await User.findById(userId);
    if (!user) return res.status(200).json({ isVip: false });

    if (user.isVip && user.subscriptionExpiresAt && new Date() > user.subscriptionExpiresAt) {
      user.isVip = false;
      await user.save();
    }
    res.status(200).json({ isVip: user.isVip });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
