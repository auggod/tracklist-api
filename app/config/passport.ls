mongoose = require('mongoose')
LocalStrategy = require('passport-local').Strategy
SoundCloudStrategy = require('passport-soundcloud').Strategy
User = require('../models/user')

module.exports = (passport, config) ->
  # require('./initializer')
  # serialize sessions
  passport.serializeUser (user, done) ->
    done null, user.id
  passport.deserializeUser (id, done) ->
    User.findOne _id: id, (err, user) ->
      done err, user

  # use local strategy
  passport.use new LocalStrategy do
    usernameField: 'username'
    passwordField: 'password', (username, password, done) ->
      User.findOne username: username, (err, user) ->
        return done(err) if err
        return done(null, false, message: 'Unknown user') if not user
        return done(null, false, message: 'Invalid password') if not user.authenticate(password)
        done null, user

  passport.use new SoundCloudStrategy do
    clientID: config.soundcloud.clientID
    clientSecret: config.soundcloud.clientSecret 
    callbackURL: config.soundcloud.callbackURL, (accessToken, refreshToken, profile, done) ->
      User.findOne 'soundcloud.id': profile.id, (err, user) ->
        if not user
          user = new User do
            name: profile.displayName
            email: profile.emails[0].value
            username: profile.username
            provider: 'soundcloud'
            soundcloud: profile._json
          user.save (err) ->
            console.log err if err
            done err, user
        else
          done(err, user) if user
