var latiniseJs = require('../config/latinise');

exports.setPermalink = function SetPermalink (permalink) {

  'use strict';

  // Latinise
  // http://stackoverflow.com/questions/990904/javascript-remove-accents-in-strings

  var Latinise={};Latinise.latin_map=latiniseJs;
  String.prototype.latinise=function(){return this.replace(/[^A-Za-z0-9\[\] ]/g,function(a){return Latinise.latin_map[a]||a})};
  String.prototype.latinize=String.prototype.latinise;
  String.prototype.isLatin=function(){return this==this.latinise()};

  return permalink
    .split(' ').join('-')
    .split("'").join('-')
    .toLowerCase()
    .latinize();
};
