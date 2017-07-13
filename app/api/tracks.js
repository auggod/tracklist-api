// Generated by LiveScript 1.4.0
(function(){
  var async, _, utils, Event, Track;
  async = require('async');
  _ = require('lodash');
  utils = require('../lib/utils');
  Event = require('../models/event');
  Track = require('../models/track');
  module.exports = {
    create: function(req, res, next){
      return async.waterfall([
        function(callback){
          if (req.query.event != null) {
            return Event.findOne({
              id: req.query.event
            }).exec(function(err, event){
              if (err) {
                return next(err);
              }
              return callback(null, event);
            });
          } else {
            return callback(null, null);
          }
        }, function(event, callback){
          var track;
          if (event != null) {} else {
            return track = new Track({
              uri: req.body.uri,
              url: req.body.url
            }).save(function(err, track){
              if (err) {
                return next(err);
              }
              return callback(track);
            });
          }
        }
      ], function(track){
        return res.status(201).json(track);
      });
    },
    list: function(req, res, next){
      return async.waterfall([
        function(callback){
          if (req.query.event != null) {
            return Event.findOne({
              id: req.query.event
            }).exec(function(err, event){
              if (err) {
                return next(err);
              }
              return callback(null, event);
            });
          } else {
            return callback(null, null);
          }
        }, function(event, callback){
          if (event != null) {} else {
            return Track.find().exec(function(err, tracks){
              if (err != null) {
                return next(err);
              }
              return callback(tracks);
            });
          }
        }
      ], function(tracks){
        if (!tracks.length) {
          return res.status(404).send('Nothing was found');
        }
        return res.json({
          tracks: tracks
        });
      });
    },
    show: function(req, res, next){
      return Track.findOne({
        id: req.params.trackId
      }).populate('_event').select('id title _event ref uri createdAt').exec(function(err, track){
        return res.json({
          track: track
        });
      });
    },
    update: function(req, res, next){},
    destroy: function(req, res){
      var updateEvent, findTrack;
      updateEvent = function(track){
        return Event.update({
          id: req.params.eventId,
          $pull: {
            'tracks': {
              _track: track.id
            }
          }
        }).exec(function(err, numAffected, rawResponse){
          if (err) {
            return next(err);
          }
          console.log('The number of updated documents was %d', numAffected);
          return console.log('The raw response from Mongo was ', rawResponse);
        });
      };
      findTrack = function(cb){
        return Track.findOne({
          id: req.params.trackId
        }, function(err, track){
          if (err) {
            return next(err);
          }
          track.remove(function(err){
            if (err) {
              return next(err);
            }
            console.log('Track deleted');
            return res.json(track);
          });
          return cb(track);
        });
      };
      return findTrack(function(track){
        return updateEvent(track);
      });
    }
  };
}).call(this);
