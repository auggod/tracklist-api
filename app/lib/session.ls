mongoose = require('mongoose')

exports.isAuthentificated = (sessionId) ->
  mongoose.connection.db.collection 'sessions', (err, collection) ->
    collection.findOne '_id': sessionId, (err, res) ->
      session = JSON.parse res.session
