const express = require('express');
const Route = express.Router();

const image = require('./routes/image');

Route.use('/image', image);

module.exports = Route;