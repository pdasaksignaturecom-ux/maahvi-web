const express = require('express');
const router = express.Router();
const { 
  getResultsByState, 
  getLatestResult, 
  createResult, 
  getResultById, 
  downloadResultPDF,
  deleteResult
} = require('../controllers/resultController');

router.route('/').post(createResult);
router.route('/:stateId').get(getResultsByState);
router.route('/:stateId/latest').get(getLatestResult);
router.route('/detail/:id').get(getResultById);
router.route('/download/:id').get(downloadResultPDF);
router.route('/:id').delete(deleteResult); // ডিলিট রাউট যোগ করা হলো

module.exports = router;
