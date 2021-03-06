// Generated by LiveScript 1.4.0
(function(){
  var mongoose, autoIncrement, slug, mongoosastic, Schema, VenueSchema, Venue, stream, count;
  mongoose = require('mongoose');
  autoIncrement = require('mongoose-auto-increment');
  slug = require('../lib/slug');
  mongoosastic = require('mongoosastic');
  Schema = mongoose.Schema;
  autoIncrement.initialize(mongoose);
  VenueSchema = new Schema({
    id: Number,
    events: [{
      _event: {
        type: Number,
        ref: 'Event'
      }
    }],
    artists: [{
      _artist: {
        type: Number,
        ref: 'Artist'
      }
    }],
    permalink: {
      type: String,
      set: slug.setSlug
    },
    name: String,
    title: String,
    image: {
      name: {
        type: String,
        'default': 'default.jpg'
      }
    },
    kind: {
      type: String,
      'default': 'festival'
    }
  }, {
    strict: true
  });
  VenueSchema.methods = {};
  VenueSchema.plugin(mongoosastic);
  VenueSchema.plugin(autoIncrement.plugin, {
    model: 'Venue',
    field: 'id',
    startAt: 1,
    incrementBy: 1
  });
  Venue = mongoose.model('Venue', VenueSchema);
  stream = Venue.synchronize();
  count = 0;
  module.exports = mongoose.model('Venue', VenueSchema);
}).call(this);
