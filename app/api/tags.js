// Generated by LiveScript 1.4.0
(function(){
  var Tag;
  Tag = require('../models/tag');
  module.exports = {
    list: function(req, res, next){
      return Tag.find().select('-id id text').exec(function(err, tags){
        if (err) {
          return next(err);
        }
        return res.json({
          tags: tags
        });
      });
    },
    show: function(req, res){},
    create: function(req, res){},
    update: function(req, res){},
    remove: function(req, res){}
  };
}).call(this);
