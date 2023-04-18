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
