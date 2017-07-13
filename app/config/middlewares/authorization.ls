require! {
  mongoose
  '../../models/event': Event
  async
  lodash: _
}

exports.requiresLogin = (req, res, next) ->
  unless req.headers['x-tracklist-session-id']
    return res.status(500).send(error: 'You are not authorized to access this ressource')
  mongoose.connection.db.collection 'sessions', (err, collection) ->
    collection.findOne { '_id': req.headers['x-tracklist-session-id'] }, (err, res) ->
      session = JSON.parse(res.session)
      if Boolean(session != undefined)
        # Set req.user
        req.user = session.passport.user
        next()
      else
        res.status(500).send(error: 'You are not authorized to access this ressource')

exports.eventAuth = (req, res, next) ->
  eventId = req.params.id
  mongoose.connection.db.collection 'sessions', (err, collection) ->
    collection.findOne { '_id': req.headers['x-tracklist-session-id'] }, (err, res) ->
      session = JSON.parse(res.session)
      if Boolean(session != undefined)
        return next()
      else
        res.status(500).send 401, error: 'You are not authorized to access this ressource'
