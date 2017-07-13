# Tracklist API
# Author: dev@auggod.io
# File: app/server/api/artists.ls

require! {
  mongoose
  async
  lodash: _
  '../models/artist': Artist
  '../models/label': Label
  '../models/user': User
}

module.exports =

  list: (req, res, next) ->

    q = req.params.q or req.query.q

    if q?
      Artist.search { "multi_match":
        "fields":  [ "name", "label.name" ],
        "query": q,
        "fuzziness": "AUTO" }, {
        hydrate: true
        hydrateOptions: select: 'id name slug'
      }, (err, results) ->
          data = []
          if results
            for item in results.hits.hits
              data.push(item)
          res.json data
      return

    Artist.find!
    .sort updatedAt: -1
    .exec (err, artists) ->
      return next err if err
      res.json artists: artists

  create: (req, res, next) ->

    ## Request example:
    ##  {
    ##    "artists": [
    ##      "Ellen Allien",
    ##      "Paul Kalkbrenner"
    ##    ],
    ##    "common":{
    ##      "label": "BPitch Control"
    ##    }
    ##  }
    #

    filter = (artists, data=[]) ->
      #_.each artists, (artist) ->
      Artist.find name: { $in : artists }
        .exec (err, artists) ->
          return next err if err
          return console.log artists

    batch = (artists) ->
      return Artist.create artists, (err, data) ->
        return next err if err
        data

    # Iterate over each artist for better handling of dupes and updates
    # Should in fact allow dupes... because in some cases, bands could have the same name or really similar name
    # Should check other things...
    # - label, genre, origin
    if req.body.artists? and _.isArray(req.body.artists)
      async.each req.body.artists, (item, callback) ->
        Artist.findOne do
          name: item
        .exec (err, results) ->
          return next err if err
          if results
            Artist.update do
              * name: item
              * $addToSet: labels: req.body.common.label
              * upsert: true, safe: true
            .exec (err) ->
              return callback err if err
              callback!
          else
            artist = new Artist do
              name: item
              slug: item
              label: name: req.body.common.label
              labels: [req.body.common.label]
            .save (err, artist) ->
              return callback err if err
              callback!
      , (err) ->
        # Callback called when all iterator functions have finished, or an error occurs.
        if err then return console.log 'Something failed to process'
        console.log 'All artists have been processed successfully'
        res.sendStatus(201)
    else
      artist = new Artist do
        name: req.body.name
        slug: req.body.name
        label: name: req.body.common.label
        labels: [req.body.common.label]
      .save (err, artist) ->
        return next err if err
        res.json artist

  show: (req, res, next) ->

    return res.sendStatus 400 if _.isNaN(req.params.id)

    population = [
      * path: 'events._event'
      * path: \images._image
      #* path: \label._label
    ]

    Artist.findOne id: req.params.id
    .populate population
    .exec (err, artist) ->
      return next err if err
      return res.sendStatus 404 if not artist
      res.json artist


  remove: (req, res, next) ->

    # Hide the resource
    hide = (id, done) ->
      Artist.findOneAndUpdate do
        * id: id
        * hidden: true
        * upsert: true
        (err, data) ->
          return next err if err
          done(data)

    # Actually remove the resource
    destroy = (id, done) ->
      Artist
      .remove id: id
      .exec (err, artist) ->
        return next err if err
        done(artist)

  update: (req, res, next) ->

    return res.sendStatus 400 if isNaN(req.params.id)

    Artist.findOneAndUpdate do
      id: req.params.id
      req.body
      upsert: true
      (err, artist) ->
        return next err if err
        if req.body.label then findCreateUpdateLabel(artist, req.body.label.name) else res.sendStatus 200

    findCreateUpdateLabel = (artist, labelName) ->
      Label.findOne do
        name: labelName
        artists: $elemMatch: _artist: artist.id
        (err, label) ->
          switch
          case label and label.artists.length
            return res.sendStatus 200
          case label and not label.artists.length
            Label.update do
              id: label.id,
              $push: 'artists': _artist: artist.id, name: artist.name
              (err, numAffected, rawResponse) ->
                res.sendStatus 200
          case not label
            label = new Label do
              name: req.body.label.name
              permalink: req.body.label.name
              artists: [
                _artist: artist.id
                name: artist.name
              ]
            .save (err, label) ->
              throw err if err
              res.sendStatus 200
