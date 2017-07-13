require! {
  async
  lodash: _
  '../lib/utils'
  '../models/event': Event
  '../models/track': Track
}

module.exports =

  create: (req, res, next) ->
    
    async.waterfall [
      (callback) ->
        if req.query.event?
          Event.findOne do
            id: req.query.event
          .exec (err, event) ->
            return next err if err
            callback null event
        else
          callback null null
      (event, callback) ->
        if event?
          return
        else
          # Create a new track
          track = new Track do
            uri: req.body.uri
            url: req.body.url
          .save (err, track) ->
            return next err if err
            callback track

        /*
        Track.findOne do
          uri: req.body.uri
        .exec (err, track) ->
          switch
          case not track
            tracks.save (track) ->
              Track.find events: $elemMatch: _event: event.id
              .exec (err, data) ->

              Track.update do
                id: track.id
                $push: 'events': _event: event.id
              .exec (err, numAffected, rawResponse) ->
                return next err if err
                console.log 'The number of updated documents was %d', numAffected
                console.log 'The raw response from Mongo was ', rawResponse

              Event.update do
                id: event.id
                $push: 'tracks': _track: track.id
              (err, numAffected, rawResponse) ->
                return next err if err
                console.log 'The number of updated documents was %d', numAffected
                console.log 'The raw response from Mongo was ', rawResponse
          case track
            console.log 'Track already exist'
            # Check if already exist for this event
            Event.find do
              tracks: $elemMatch: _track: track.id
            .exec (err, data) ->
              console.log data

              Event.update do
                id: event.id
                $push: 'tracks': _track: track.id
              (err, numAffected, rawResponse) ->
                return next err if err
                console.log 'The number of updated documents was %d', numAffected
                console.log 'The raw response from Mongo was ', rawResponse
          */

    ], (track) ->
      res.status 201 .json track

  list: (req, res, next) ->

    async.waterfall [
      (callback) ->
        if req.query.event?
          Event.findOne do
            id: req.query.event
          .exec (err, event) ->
            return next err if err
            callback null event
        else
          callback null null
      (event, callback) ->
        if event?
          return
        else
          Track.find!
          .exec (err, tracks) ->
            return next err if err?
            callback tracks
    ], (tracks) ->
      return res.status 404 .send 'Nothing was found' if not tracks.length
      res.json tracks: tracks

  show: (req, res, next) ->
    Track.findOne do
      id: req.params.trackId
    .populate '_event'
    .select 'id title _event ref uri createdAt'
    .exec (err, track) ->
      res.json track: track

  update: (req, res, next) ->

  destroy: (req, res) ->

    updateEvent = (track) ->
      Event.update do
        id: req.params.eventId
        $pull: 'tracks': _track: track.id
      .exec (err, numAffected, rawResponse) ->
        return next err if err
        console.log 'The number of updated documents was %d', numAffected
        console.log 'The raw response from Mongo was ', rawResponse

    findTrack = (cb) ->
      Track.findOne id: req.params.trackId, (err, track) ->
        return next err if err
        track.remove (err) ->
          return next err if err
          console.log 'Track deleted'
          res.json track
        cb(track)

    findTrack (track) ->
      updateEvent track
