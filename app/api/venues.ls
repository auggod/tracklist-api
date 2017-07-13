require! '../models/venue': Venue

module.exports =

  list: (req, res, next) ->

    q = req.params.q or req.query.q

    if q?
      Venue.search { "multi_match":
        "fields":  [ "name"],
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

    Venue.find!
    .select '-events -artists'
    .exec (err, venues) ->
      return next err if err
      res.json venues: venues      

  create: (req, res, next) ->
    venue = new Venue do
      name: req.body.name
    .save (err, venue) ->
      return next err if err
      res.json venue
      
  update: (req, res, next) ->
    Venue.findOneAndUpdate do
      id: req.params.id
      req.body
      upsert: true
      (err, venue) ->
        return next err if err
        res.json venue

  show: (req, res, next) ->
    Venue.findOne permalink: req.params.permalink
    .populate path: 'events._event'
    .exec (err, venue) ->
      return next err if err
      res.json venue

  remove: (req, res, next) ->
    Venue.remove id: req.params.id
    .exec (err, venue) ->
      return next err if err
