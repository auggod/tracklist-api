_ = require 'lodash'
cors = require 'cors'

module.exports = (app, passport) ->

  #Require all the things
  require! {
    '../api/tracks'
    '../api/events'
    '../api/artists'
    '../api/search'
    '../api/labels'
    '../api/venues'
    '../api/users'
  }

  images = require('../api/images')

  #Auth middlewares
  auth = require './middlewares/authorization'

  app.use '*', (req, res, next) ->
    console.log req.user
    next!

  whitelist = [
    'https://dev.tracklistapp.com'
  ]

  corsOptionsDelegate = (req, callback) ->
    corsOptions = undefined
    if whitelist.indexOf(req.header('Origin')) != -1
      corsOptions = do
        origin: true
        credentials: true
      # reflect (enable) the requested origin in the CORS response
    else
      corsOptions = origin: false
      # disable CORS for this request
    callback null, corsOptions
    # callback expects two parameters: error and options
    return

  app.use(cors(corsOptionsDelegate))

  rest = (nameController, controller) ->
    app.get "/#nameController"        controller.list   if controller.list
    app.get "/#nameController/:id"    controller.show   if controller.show
    app.post "/#nameController"       controller.create if controller.create
    app.put "/#nameController/:id"    controller.update if controller.update
    app.delete "/#nameController/:id" controller.remove if controller.remove

  #Auth, users
  app.get '/logout', users.logout
  app.post '/users', users.create
  app.get '/user', users.auth
  app.get '/user/:userId', events.findUser
  app.get '/users/:username', users.show
  app.post '/users/session', (passport.authenticate 'local'), users.auth
  app.put '/users/:username', users.update
  app.delete '/users/:username', users.remove
  app.get '/users/pages/:page', users.list

  #Events TODO pagination optional
  app.get '/events/:id', events.show
  app.get '/events/:q?/:tags?/:active?/:limit?/:archive?/:username?', events.list

  app.get '/events/user/:username', events.findUserEvents
  app.post '/events', events.create
  app.put '/events/:id/images', events.addImages
  app.put '/events/:id', events.update
  app.delete '/events/:id', events.destroy

  #Tracks
  app.get '/tracks/:event?', tracks.list
  app.get '/tracks/:id', tracks.show
  app.post '/tracks/:event?', tracks.create
  app.delete '/tracks/:id/:event?', tracks.destroy

  #Labels
  app.get '/labels', labels.list
  app.get '/labels/:permalink', labels.show
  app.post '/labels', labels.create
  app.put '/labels/:permalink', labels.update
  app.delete '/labels/:permalink', labels.remove

  #Tags
  rest "tags" require('../api/tags')

  #Artists
  app.get '/artists/:id', artists.show
  app.get '/artists/:q?', artists.list
  app.post '/artists', artists.create
  app.put '/artists/:permalink', artists.update

  #Upload
  app.post '/upload/', images.upload

  #Venues
  app.get '/venues/:q?', venues.list
  app.get '/venues/:permalink', venues.show

  app.get '*', (req, res) ->
    res.send 'Tracklist API is running'
