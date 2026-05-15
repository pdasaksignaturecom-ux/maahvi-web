const express = require('express');
const router = express.Router();
const { 
  getPredictionsByState, 
  createPrediction, 
  getLatestPrediction,
  deletePrediction,
  createBulkPredictions
} = require('../controllers/predictionController');

router.route('/').post(createPrediction);
router.route('/bulk').post(createBulkPredictions);
router.route('/:stateId').get(getPredictionsByState);
router.route('/:stateId/latest').get(getLatestPrediction);
router.route('/:id').delete(deletePrediction);

module.exports = router;
