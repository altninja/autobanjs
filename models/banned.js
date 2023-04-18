const mongoose = require('mongoose');

const bannedSchema = new mongoose.Schema({
  ip: { type: String, required: true },
  userAgent: { type: String, required: true }
});

module.exports = mongoose.model('Banned', bannedSchema);
