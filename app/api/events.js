// Generated by LiveScript 1.4.0
(function(){
  var async, _, utils, Event, Artist, Venue, Track, Tag, User;
  async = require('async');
  _ = require('lodash');
  utils = require('../lib/utils');
  Event = require('../models/event');
  Artist = require('../models/artist');
  Venue = require('../models/venue');
  Track = require('../models/track');
  Tag = require('../models/tag');
  User = require('../models/user');
  module.exports = {
    create: function(req, res, next){
      var user, act, venue, event;
      user = req.user;
      act = req.body.act;
      venue = req.body.venue || req.body.title;
      if (user) {
        return User.findOne({
          _id: user
        }).exec(function(err, usr){
          var event;
          if (err) {
            return next(err);
          }
          event = new Event({
            _usr: usr,
            venue: req.body.venue,
            act: req.body.act,
            slug: act + '-' + venue
          }).save(function(err, event){
            if (err) {
              return next(err);
            }
            return res.json(event);
          });
        });
      } else {
        return event = new Event({
          venue: req.body.venue,
          act: req.body.act,
          slug: act + ' ' + venue
        }).save(function(err, event){
          if (err) {
            return next(err);
          }
          return res.json(event);
        });
      }
    }
    /*
    list: (req, res, next) ->
    
      return res.status 400 .send message: error: 'Missing some ids' if req.query.ids?
    
      Event.find!
      .where 'id'
      .in req.query.ids
      .exec (err, events) ->
        return next err if err
        res.json events: events
    */,
    list: function(req, res, next){
      var tags, now, thisYear, nextYear, timeframe, q, pastMonth, nextMonth, isActive;
      console.log(req);
      tags = req.params.tags || req.query.tags;
      if (tags != null) {
        tags = _.map(tags.split('+'), function(data){
          return data;
        });
        now = new Date();
        thisYear = new Date().getFullYear();
        nextYear = new Date().setFullYear(thisYear + 1);
        timeframe = {
          $gt: now,
          $lt: nextYear
        };
        Event.find({
          active: true
        }).where('tags.text')['in'](tags).sort({
          date: 1
        }).limit(100).select('-_user').exec(function(err, events){
          if (err) {
            return next(err);
          }
          return res.json({
            events: events
          });
        });
        return;
      }
      q = req.params.q || req.query.q;
      if (q != null) {
        Event.search({
          "multi_match": {
            "fields": ["act", "title", "venue", "tags.text"],
            "query": q,
            "fuzziness": "AUTO"
          }
        }, {
          hydrate: true,
          hydrateOptions: {
            select: 'id title tags act venue slug permalink date'
          }
        }, function(err, results){
          var data, i$, ref$, len$, item;
          if (results == null) {
            return;
          }
          if (results.hits.total === 0) {
            return res.json({});
          }
          data = [];
          for (i$ = 0, len$ = (ref$ = results.hits.hits).length; i$ < len$; ++i$) {
            item = ref$[i$];
            data.push(item);
          }
          return res.json(data);
        });
        return;
      }
      now = new Date();
      thisYear = new Date().getFullYear();
      pastMonth = new Date().setMonth(new Date().getMonth() - 1);
      nextMonth = new Date().setMonth(new Date().getMonth() + 1);
      nextYear = new Date().setFullYear(thisYear + 1);
      timeframe = {
        $gt: pastMonth,
        $lt: nextYear
      };
      if (req.query.archive && req.query.archive === '1') {
        timeframe = {
          $lt: now
        };
      }
      isActive = true;
      if (req.query.active != null) {
        isActive = req.query.active !== '0' ? true : false;
      }
      return async.waterfall([
        function(callback){
          if (!req.query.username) {
            return callback(null, null);
          }
          return User.findOne({
            username: req.query.username
          }).exec(function(err, user){
            if (err) {
              return next(err);
            }
            if (user) {
              return callback(null, user);
            }
          });
        }, function(user, callback){
          switch (false) {
          case !user:
            return Event.find({
              _user: user._id
            }).sort({
              date: 1
            }).exec(function(err, events){
              if (err) {
                return next(err);
              }
              return callback(events);
            });
          case !!user:
            return Event.find({
              active: isActive,
              date: timeframe
            }).sort({
              date: 1
            }).populate({
              path: '_user',
              select: '-_id name username account_type label avatar'
            }).exec(function(err, events){
              if (err) {
                return next(err);
              }
              return callback(events);
            });
          }
        }
      ], function(events){
        return Event.count({
          active: isActive,
          date: timeframe
        }).exec(function(err, count){
          if (err) {
            return next(err);
          }
          return res.json({
            events: events
          });
        });
      });
    },
    tags: function(req, res, next){
      var tags, now, thisYear, nextYear, timeframe;
      tags = _.map(req.params.tags.split('+'), function(data){
        return _.escapeRegExp(data);
      });
      now = new Date();
      thisYear = new Date().getFullYear();
      nextYear = new Date().setFullYear(thisYear + 1);
      timeframe = {
        $gt: now,
        $lt: nextYear
      };
      return Event.find({
        active: true
      }).where('tags.text')['in'](tags).sort({
        date: 1
      }).limit(100).select('-_user').exec(function(err, events){
        if (err) {
          return next(err);
        }
        return res.json({
          events: events
        });
      });
    },
    show: function(req, res, next){
      var id, population;
      if (!req.params.id) {
        return res.status(400).send('Bad request');
      }
      id = _.parseInt(req.params.id);
      if (isNaN(id)) {
        return res.status(400).send('Bad request');
      }
      population = [
        {
          path: '_user',
          select: '-_id name username account_type label avatar'
        }, {
          path: '_artist',
          select: '-events -images'
        }, {
          path: 'tracks._track',
          select: '-events -createdAt -id'
        }, {
          path: 'images._image'
        }
      ];
      return Event.findOne({
        id: id
      }).populate(population).exec(function(err, event){
        if (err) {
          return next(err);
        }
        return res.json(event);
      });
    },
    findUserEvents: function(req, res, next){
      return Event.find({
        _user: req.user
      }).populate({
        path: '_artist'
      }).exec(function(err, events){
        if (err) {
          return next(err);
        }
        return res.json({
          events: events
        });
      });
    },
    findUser: function(req, res, next){
      return User.findOne({
        _id: req.params.userId
      }).select('_id username label').exec(function(err, user){
        if (err) {
          return next(err);
        }
        if (!user) {
          return res.send(404, JSON.stringify('User does not exist' + err));
        }
        return res.json({
          user: user
        });
      });
    },
    addImages: function(req, res, next){
      return Event.findOneAndUpdate({
        id: req.params.id,
        $push: {
          images: {
            $each: req.body.images
          }
        },
        upsert: true
      }, function(err){
        if (err) {
          return next(err);
        }
        return res.sendStatus(200);
      });
    },
    update: function(req, res, next){
      var findAndCreateVenue, findMatchingVenues, findAndCreateArtist, addArtistToEvent, findMatchingArtists, updateArtistEvents;
      Event.findOneAndUpdate({
        id: req.params.id
      }, req.body, {
        upsert: true
      }, function(err, event){
        var i$, ref$, len$, tag;
        if (err) {
          return next(err);
        }
        if (req.body.title) {
          findAndCreateVenue(event);
        }
        if (req.body.act) {
          findAndCreateArtist(event);
        }
        if (req.body.tags) {
          /*
          
          _tags = []
          
          for item in req.body.tags
            _tags.push(item.text)
          
          Tag
            .find!
            .where 'text'
            .in _tags
            .exec (err, tags) ->
              console.log tags
          
          */
          for (i$ = 0, len$ = (ref$ = req.body.tags).length; i$ < len$; ++i$) {
            tag = ref$[i$];
            Tag.findOne({
              'text': tag.text
            }).exec(fn$);
          }
        }
        return res.json(event);
        function fn$(err, data){
          var t;
          if (err) {
            return next(err);
          }
          if (!data) {
            t = new Tag({
              'text': tag.text
            });
            return t.save();
          }
        }
      });
      findAndCreateVenue = function(event){
        return Venue.findOne({
          name: req.body.title
        }).exec(function(err, venue){
          if (!venue) {
            venue = new Venue({
              name: event.title,
              permalink: event.title,
              image: {
                name: event.image.name
              },
              events: [{
                _event: event.id
              }]
            }).save(function(err, venue){
              if (err) {
                return next(err);
              }
              return findMatchingVenues(event, venue);
            });
          }
          return findMatchingVenues(event, venue);
        });
      };
      findMatchingVenues = function(event, venue){
        return Venue.find({
          events: {
            $elemMatch: {
              _event: event.id
            }
          }
        }).exec(function(err, data){
          if (!data.length) {
            return Venue.update({
              id: venue.id,
              $push: {
                'events': {
                  _event: event.id
                }
              }
            }).exec(function(err, numAffected, rawResponse){
              if (err) {
                return next(err);
              }
            });
          }
        });
      };
      findAndCreateArtist = function(event){
        return Artist.findOne({
          name: req.body.act
        }).exec(function(err, artist){
          if (!artist) {
            artist = new Artist({
              name: event.act,
              permalink: event.act,
              image: {
                name: event.image.name
              },
              events: [{
                _event: event.id
              }]
            }).save(function(err, artist){
              if (err) {
                return next(err);
              }
              addArtistToEvent(event, artist);
              return findMatchingArtists(event, artist);
            });
          }
          addArtistToEvent(event, artist);
          return findMatchingArtists(event, artist);
        });
      };
      addArtistToEvent = function(event, artist){
        return Event.update({
          id: event.id,
          $set: {
            _artist: artist.id
          }
        }).exec(function(err, numAffected, rawResponse){
          if (err) {
            return next(err);
          }
        });
      };
      findMatchingArtists = function(event, artist){
        return Artist.find({
          events: {
            $elemMatch: {
              _event: event.id
            }
          }
        }).exec(function(err, data){
          if (!data.length) {
            return updateArtistEvents(event, artist);
          }
        });
      };
      return updateArtistEvents = function(event, artist){
        return Artist.update({
          id: artist.id,
          $push: {
            'events': {
              _event: event.id
            }
          }
        }).exec(function(err, numAffected, rawResponse){
          if (err) {
            return next(err);
          }
        });
      };
    },
    destroy: function(req, res, next){
      var removeEvent, removeTrack, updateArtist;
      User.findOne({
        _id: req.user
      }).exec(function(err, usr){
        if (err) {
          return next(err);
        }
        if (!usr) {
          return res.send(500, JSON.stringify('You must be logged'));
        }
        return Event.findOne({
          id: req.params.id
        }).exec(function(err, event){
          if (err) {
            return next(err);
          }
          if (!usr._id.equals(event._user)) {
            return res.send(500, {
              error: 'You are not authorized'
            });
          }
          removeTrack(event.id);
          updateArtist(event);
          return removeEvent(event.id);
        });
      });
      removeEvent = function(id){
        return Event.remove({
          id: id
        }).exec(function(err, event){
          if (err) {
            return next(err);
          }
        });
      };
      removeTrack = function(id){
        return Track.remove({
          _event: event.id
        }).exec(function(err, event){
          if (err) {
            return next(err);
          }
        });
      };
      return updateArtist = function(event){
        return Artist.update({
          name: event.act,
          $pull: {
            'events': {
              _event: event.id
            }
          }
        }).exec(function(err, num, raw){
          if (err) {
            return next(err);
          }
        });
      };
    }
  };
}).call(this);
