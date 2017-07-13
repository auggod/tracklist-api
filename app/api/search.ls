# Tracklist API
# Author: dev@auggod.io
# File: app/server/api/events.js

require! {
  async
  lodash: _
  '../lib/utils'
  '../models/event': Event
  '../models/artist': Artist
  '../models/label': Label
  '../models/venue': Venue
  '../models/user': User
}

module.exports =

  events: (req, res, next) ->
    return res.sendStatus 400 if not (req.params.q or req.query.q)

    q = req.params.q or req.query.q

    Event.search { "multi_match":
      "fields":  [ "act", "title", "venue" ],
      "query": q,
      "fuzziness": "AUTO" }, {
      hydrate: true
      hydrateOptions: select: 'title act venue slug permalink date'
    }, (err, results) ->
      return res.sendStatus 404 if not results
      data = []
      for item in results.hits.hits
        data.push(item)
      res.json data

    #Warning: this query can be very heavy if prefix_length and max_expansions are both set to 0
    /*
    Event.search { 'fuzzy': 'act':
      'value': q
      'boost': 1.0
      'fuzziness': 2
      'prefix_length': 0
      'max_expansions': 100 }, {
      hydrate: true
      hydrateOptions: select: 'title act venue slug permalink date'
    }, (err, results) ->
      data = []
      for item in results.hits.hits
        data.push(item)
      res.json data

    */

    /*
    Event.search { "query_string": "query": q }, {
      hydrate: true
      hydrateOptions: select: 'title act venue slug permalink date'
    }, (err, results) ->
        data = []
        for item in results.hits.hits
          data.push(item)
        res.json data
    */

  /*
  events: (req, res, next) ->

    return res.sendStatus 400 if not (req.params.q or req.query.q)

    q = req.params.q or req.query.q
    q = q.split(/[\s,+]+/)
    queryArr = _.map (q), (query) ->
      '(' + _.escapeRegExp(query) + ')'

    r = queryArr.join '|'
    r = $regex: new RegExp(r, 'i')

    Event.find active: true
    .or([
      * 'act': r
      * 'title': r
      * 'tags.text': r
    ])
    .limit 10
    .exec (err, events) ->
      return next err if err
      res.json do
        events: events

  */
      
  artists: (req, res) ->
    query = req.query.q
    r = new RegExp(query, 'i')
    Artist.find!
    .or([
      * 'name': $regex: r
    ])
    .limit(10)
    .exec (err, artists) ->      
      return next err if err
      res.json artists: artists
        

  labels: (req, res, next) ->
    r = new RegExp(req.params.q, 'i')

    Label.find!
    .or([
      * 'name': $regex: r
    ])
    .limit(10)
    .exec (err, labels) ->
      return next err if err
      res.json labels: labels      

  venues: (req, res, next) ->
    r = new RegExp(req.params.q, 'i')

    Venue.find!
    .or([
      * 'name': $regex: r
    ])
    .limit(10)
    .exec (err, venues) ->
      return next err if err
      res.json venues: venues  
            
  users: (req, res, next) ->
    r = new RegExp(req.params.q, 'i')

    User.find!
    .select 'username email name avatar lang label account_type'
    .or([
      * 'username': $regex: r
    ])
    .exec (err, users) ->
      return next err if err
      res.json users: users
