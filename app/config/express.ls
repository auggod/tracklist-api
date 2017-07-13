require! {
  morgan: logger
  'express-session': session
  'cookie-parser'
  'body-parser'
  compression: compress
  errorhandler
}

mongoStore = require('connect-mongo')(session)

module.exports = (app, config, env, passport) ->

  climate = process.env.NODE_ENV or env.get('TRACKLIST_ENV')

  app.disable 'x-powered-by'

  /*
  app.use (req, res, next) ->
    res.header 'x-powered-by', env.get('TRACKLIST_POWERED_BY')
    next!
  */

  app.use compress do
    filter: (req, res) ->
      /json|text|javascript|css/.test res.getHeader('Content-Type')
    threshold: 512

  app.use (req, res, next) ->
    res.locals.env = app.get('env')
    next!

  # don't use logger for test env
  if process.env.NODE_ENV != 'test'
    app.use logger('dev')

  if climate == 'development'
    app.use errorhandler do
      dumpExceptions: true
      showStack: true
    app.locals.pretty = true

  if climate == 'production'
    app.use errorhandler do
      dumpExceptions: false
      showStack: false

  app.set 'view engine', 'jade'
  app.locals.pretty = false
  # cookieParser should be above session
  app.use cookieParser!
  app.use bodyParser.json!
  app.use bodyParser.urlencoded extended: true

  secret = env.get('TRACKLIST_SESSION_SECRET')

  app.use session do
    secret: secret
    resave: true
    saveUninitialized: true
    key: 'sid'
    store: new mongoStore do
      url: config.db
      collection: 'sessions'
    cookie: httpOnly: true

  # use passport session
  app.use passport.initialize()
  app.use passport.session()
  app.use (req, res, next) ->
    res.setHeader 'X-UA-Compatible', 'IE=Edge,chrome=1'
    next!
