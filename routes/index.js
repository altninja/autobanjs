const express = require('express');
const router = express.Router();
const path = require('path');
const fs = require('fs');
const Banned = require('../models/banned');
const useragent = require('useragent');

router.get('/', async (req, res, next) => {
  const userAgent = useragent.parse(req.headers['user-agent']);
  const clientIP = req.ip;
  const isBanned = await Banned.findOne({ ip: clientIP });

  if (isBanned) {
    res.status(403).render('error');
  } else {
    res.render('index');
  }
});

router.post('/', async (req, res) => {
  const bannedPhrases = ['badword1', 'badword2', 'badword3'];
  const input = req.body.input;
  const userAgent = useragent.parse(req.headers['user-agent']);
  const clientIP = req.ip;

  if (bannedPhrases.includes(input)) {
    const bannedUser = new Banned({
      ip: clientIP,
      userAgent: userAgent.toString()
    });

    await bannedUser.save();
    res.render('error');
  } else {
    res.render('success');
  }
});

module.exports = router;
