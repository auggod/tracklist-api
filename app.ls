app = require('express')()
passport = require 'passport'

env = do ->
  Habitat = require('habitat')
  Habitat.load('.env')
  new Habitat

port = env.get('TRACKLIST_PORT')
climate = env.get('TRACKLIST_ENV')

config = require('./app/config/config')[climate]
mongoose = require 'mongoose'

options = do
  db: native_parser: true
  server: poolSize: 5
  #replset: { rs_name: 'myReplicaSetName' },
  #user: 'myUserName',
  #pass: 'myPassword'

mongoose.connect(config.db, options)

require('./app/config/passport') passport, config

require('./app/config/express') app, config, env, passport

require('./app/config/routes') app, passport

app.listen port, '127.0.0.1' ->
  console.log 'Tracklist API is running in ', app.get('env'), ' mode on port ', port
