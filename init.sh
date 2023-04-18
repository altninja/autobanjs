#!/bin/bash

# Create project folder and navigate inside
mkdir autoban-api
cd autoban-api

# Initialize npm and install necessary packages
npm init -y
npm install express pug body-parser ip macaddress useragent mongoose

# Create necessary folders and files
mkdir views routes models
touch app.js
touch views/index.pug views/success.pug views/error.pug
touch routes/index.js
touch models/banned.js

# Add code to the created files
cat > app.js << 'EOF'
const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const indexRouter = require('./routes/index');
const mongoose = require('mongoose');

mongoose.connect('mongodb://localhost/autoban', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

app.set('view engine', 'pug');
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/', indexRouter);

app.listen(3000, () => console.log('Server started on port 3000.'));
EOF

cat > routes/index.js << 'EOF'
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
EOF

cat > models/banned.js << 'EOF'
const mongoose = require('mongoose');

const bannedSchema = new mongoose.Schema({
  ip: { type: String, required: true },
  userAgent: { type: String, required: true }
});

module.exports = mongoose.model('Banned', bannedSchema);
EOF

cat > views/index.pug << 'EOF'
doctype html
html
  head
    title AutoBan API
    link(rel="stylesheet", href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css")
  body
    .container
      h1 AutoBan API
      form(method="post", action="/")
        .form-group
          label(for="input") Enter Text:
          input#input.form-control(type="text", name="input", required)
        button.btn.btn-primary(type="submit") Submit
EOF

cat > views/success.pug << 'EOF'
doctype html
html
  head
    title Success
    link(rel="stylesheet", href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css")
  body
    .container
      h1 Success
      p Your input has been successfully processed.
EOF

cat > views/error.pug << 'EOF'
doctype html
html
  head
    title Error
    link(rel="stylesheet", href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css")
  body
    .container
      h1 Invalid Input
      p
      | Your input was not valid and could not be processed. Please ensure that you provide appropriate input according to the guidelines.
EOF
