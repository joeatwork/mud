/* global module require __dirname */
// Cargo culted off of the internet.

var path = require('path');

module.exports = {
  entry: path.resolve(__dirname, 'src/index.jsx'),
  output: {
    path: path.resolve(__dirname, 'public/build'),
    filename: 'bundle.js',
  },
   module : {
    loaders : [
      {
        test : /\.jsx?/,
        include : path.resolve(__dirname, 'src'),
        loader : 'babel-loader',
      },
    ],
   },
};
