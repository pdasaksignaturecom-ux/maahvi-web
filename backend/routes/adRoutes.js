const express = require('express');
const router = express.Router();
const { getAds, createAd, updateAd, deleteAd } = require('../controllers/adController');

router.route('/')
  .get(getAds)
  .post(createAd);

router.route('/:id')
  .put(updateAd)
  .delete(deleteAd);

module.exports = router;
