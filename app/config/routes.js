// Generated by LiveScript 1.4.0
(function(){
  var _, cors;
  _ = require('lodash');
  cors = require('cors');
  module.exports = function(app, passport){
    var tracks, events, artists, search, labels, venues, users, images, auth, whitelist, corsOptionsDelegate, rest;
    tracks = require('../api/tracks');
    events = require('../api/events');
    artists = require('../api/artists');
    search = require('../api/search');
    labels = require('../api/labels');
    venues = require('../api/venues');
    users = require('../api/users');
    images = require('../api/images');
    auth = require('./middlewares/authorization');
    app.use('*', function(req, res, next){
      console.log(req.user);
      return next();
    });
    whitelist = ['https://dev.tracklistapp.com'];
    corsOptionsDelegate = function(req, callback){
      var corsOptions;
      corsOptions = undefined;
      if (whitelist.indexOf(req.header('Origin')) !== -1) {
        corsOptions = {
          origin: true,
          credentials: true
        };
      } else {
        corsOptions = {
          origin: false
        };
      }
      callback(null, corsOptions);
    };
    app.use(cors(corsOptionsDelegate));
    rest = function(nameController, controller){
      if (controller.list) {
        app.get("/" + nameController, controller.list);
      }
      if (controller.show) {
        app.get("/" + nameController + "/:id", controller.show);
      }
      if (controller.create) {
        app.post("/" + nameController, controller.create);
      }
      if (controller.update) {
        app.put("/" + nameController + "/:id", controller.update);
      }
      if (controller.remove) {
        return app['delete']("/" + nameController + "/:id", controller.remove);
      }
    };
    app.get('/logout', users.logout);
    app.post('/users', users.create);
    app.get('/user', users.auth);
    app.get('/user/:userId', events.findUser);
    app.get('/users/:username', users.show);
    app.post('/users/session', passport.authenticate('local'), users.auth);
    app.put('/users/:username', users.update);
    app['delete']('/users/:username', users.remove);
    app.get('/users/pages/:page', users.list);
    app.get('/events/:id', events.show);
    app.get('/events/:q?/:tags?/:active?/:limit?/:archive?/:username?', events.list);
    app.get('/events/user/:username', events.findUserEvents);
    app.post('/events', events.create);
    app.put('/events/:id/images', events.addImages);
    app.put('/events/:id', events.update);
    app['delete']('/events/:id', events.destroy);
    app.get('/tracks/:event?', tracks.list);
    app.get('/tracks/:id', tracks.show);
    app.post('/tracks/:event?', tracks.create);
    app['delete']('/tracks/:id/:event?', tracks.destroy);
    app.get('/labels', labels.list);
    app.get('/labels/:permalink', labels.show);
    app.post('/labels', labels.create);
    app.put('/labels/:permalink', labels.update);
    app['delete']('/labels/:permalink', labels.remove);
    rest("tags", require('../api/tags'));
    app.get('/artists/:id', artists.show);
    app.get('/artists/:q?', artists.list);
    app.post('/artists', artists.create);
    app.put('/artists/:permalink', artists.update);
    app.post('/upload/', images.upload);
    app.get('/venues/:q?', venues.list);
    app.get('/venues/:permalink', venues.show);
    return app.get('*', function(req, res){
      return res.send('Tracklist API is running');
    });
  };
}).call(this);
