// Generated by LiveScript 1.4.0
(function(){
  var mongoose, autoIncrement, Schema, TagSchema;
  mongoose = require('mongoose');
  autoIncrement = require('mongoose-auto-increment');
  Schema = mongoose.Schema;
  autoIncrement.initialize(mongoose);
  TagSchema = new Schema({
    __v: {
      type: Number,
      select: false
    },
    id: Number,
    count: {
      type: Number,
      'default': 1
    },
    text: String
  });
  TagSchema.plugin(autoIncrement.plugin, {
    model: 'Tag',
    field: 'id',
    startAt: 1,
    incrementBy: 1
  });
  module.exports = mongoose.model('Tag', TagSchema);
}).call(this);
