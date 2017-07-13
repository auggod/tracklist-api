require! {
  async
  lodash: _
  '../lib/utils'
  '../models/event': Event
  '../models/artist': Artist
  '../models/venue': Venue
  '../models/track': Track
  '../models/tag': Tag
  '../models/user': User
}

module.exports =

  create: (req, res, next) ->

    #return res.sendStatus 400 if not req.user

    user = req.user
    act = req.body.act
    venue = req.body.venue or req.body.title

    if user
      User.findOne _id: user
      .exec (err, usr) !->
        return next err if err
        event = new Event do
          _usr: usr
          venue: req.body.venue
          act: req.body.act
          slug: act + '-' + venue
        .save (err, event) ->
          return next err if err
          res.json event
    else
      event = new Event do
        venue: req.body.venue
        act: req.body.act
        slug: act + ' ' + venue
      .save (err, event) ->
        return next err if err
        res.json event

  /*
  list: (req, res, next) ->

    return res.status 400 .send message: error: 'Missing some ids' if req.query.ids?

    Event.find!
    .where 'id'
    .in req.query.ids
    .exec (err, events) ->
      return next err if err
      res.json events: events
  */

  #Events TODO pagination optional

  list: (req, res, next) ->

    # Tags
    console.log req

    tags = req.params.tags or req.query.tags

    if tags?
      tags = _.map tags.split('+'), (data) ->
        data
        #_.escapeRegExp(data)

      now = new Date!
      thisYear = new Date!getFullYear!
      nextYear = new Date!setFullYear thisYear + 1

      timeframe = do
        $gt: now
        $lt: nextYear

      Event.find active: true
      .where 'tags.text'
      .in(tags)
      .sort date: 1
      .limit(100)
      .select '-_user'
      .exec (err, events) ->
        return next err if err
        res.json events: events
      return

    # Elasticsearch search query

    q = req.params.q or req.query.q

    if q?
      Event.search { "multi_match":
        "fields":  [ "act", "title", "venue", "tags.text" ],
        "query": q,
        "fuzziness": "AUTO" }, {
        hydrate: true
        hydrateOptions: select: 'id title tags act venue slug permalink date'
      }, (err, results) ->
        return if not results?
        if results.hits.total == 0 then
          return res.json({})
        data = []
        for item in results.hits.hits
          data.push(item)
        res.json data
      return

    # return res.status 400 .send message: error: 'Missing param for pages' if not req.params.page

    # Starting

    now = new Date!
    thisYear = new Date!getFullYear!
    pastMonth = new Date!setMonth new Date!getMonth! - 1
    nextMonth = new Date!setMonth new Date!getMonth! + 1
    nextYear = new Date!setFullYear thisYear + 1

    timeframe = do
      $gt: pastMonth
      $lt: nextYear

    if req.query.archive and req.query.archive == '1'
      timeframe = $lt: now

    #perPage = req.query.limit or 10
    #page = req.params.page > 0 ? req.params.page : 0
    #pageNumber = _.parseInt(req.params.page)  + 1
    isActive = true

    if req.query.active?
      isActive = if req.query.active != '0' then true else false

    async.waterfall [
      (callback) ->

        return callback null null if not req.query.username

        User.findOne username: req.query.username
        .exec (err, user) ->
          return next err if err
          callback null user if user
      (user, callback) ->
        switch
        case user
          Event.find do
            _user: user._id
          .sort date: 1
          #.limit perPage
          #.skip perPage * page
          .exec (err, events) ->
            return next err if err
            callback events
        case not user
          Event.find do
            active: isActive
            date: timeframe
          .sort date: 1
          .populate do
            path: '_user'
            select: '-_id name username account_type label avatar'
          #.limit perPage
          #.skip perPage * page
          .exec (err, events) ->
            return next err if err
            callback events
      ], (events) ->
        Event.count do
          active: isActive
          date: timeframe
        .exec (err, count) ->
          return next err if err
          #countPerPage = count / perPage
          res.json do
            events: events
            #page: page
            #pages: countPerPage
            #next: (countPerPage / pageNumber > 1 ? true : false)

  tags: (req, res, next) ->

    tags = _.map (req.params.tags.split '+'), (data) ->
      _.escapeRegExp(data)

    now = new Date!
    thisYear = new Date!getFullYear!
    nextYear = new Date!setFullYear thisYear + 1

    timeframe = do
      $gt: now
      $lt: nextYear

    Event.find active: true
    .where 'tags.text'
    .in(tags)
    .sort date: 1
    .limit(100)
    .select '-_user'
    .exec (err, events) ->
      return next err if err
      res.json events: events

  show: (req, res, next) ->
    return res.status 400 .send 'Bad request' if not req.params.id

    id = _.parseInt req.params.id

    return res.status 400 .send 'Bad request' if isNaN id

    population = [
      * path: '_user'
        select: '-_id name username account_type label avatar'
      * path: '_artist'
        select: '-events -images'
      * path: 'tracks._track'
        select: '-events -createdAt -id'
      * path: 'images._image'
    ]

    Event.findOne do
      id: id
    .populate population
    .exec (err, event) ->
      return next err if err
      res.json event

  findUserEvents: (req, res, next) ->
    Event.find _user: req.user
    .populate path: '_artist'
    .exec (err, events) ->
      return next err if err
      res.json events: events

  findUser: (req, res, next) ->
    User.findOne _id: req.params.userId
    .select '_id username label'
    .exec (err, user) ->
      return next err if err
      return res.send 404 JSON.stringify 'User does not exist' + err if not user
      res.json user: user

  addImages: (req, res, next) ->

    Event.findOneAndUpdate do
      id: req.params.id
      $push: images: $each: req.body.images
      upsert: true
      (err) ->
        return next err if err
        res.sendStatus 200


  update: (req, res, next) ->

    #TODO waterfall async

    Event.findOneAndUpdate do
      id: req.params.id
      req.body
      upsert: true
      (err, event) ->
        return next err if err

        if req.body.title then findAndCreateVenue(event)

        if req.body.act then findAndCreateArtist(event)

        if req.body.tags

          /*

          _tags = []

          for item in req.body.tags
            _tags.push(item.text)

          Tag
            .find!
            .where 'text'
            .in _tags
            .exec (err, tags) ->
              console.log tags

          */

          for tag in req.body.tags

            Tag.findOne 'text': tag.text
            .exec (err, data) ->
              return next err if err
              unless data
                t = new Tag do
                  'text': tag.text
                t.save!

        res.json event

    findAndCreateVenue = (event) ->
      Venue.findOne name: req.body.title
      .exec (err, venue) ->
        unless venue
          venue = new Venue do
            name: event.title
            permalink: event.title
            image: name: event.image.name
            events: [_event: event.id]
          .save (err, venue) ->
            return next err if err
            findMatchingVenues(event, venue)

        return findMatchingVenues(event, venue)

    findMatchingVenues = (event, venue) ->
      Venue.find events: $elemMatch: _event: event.id
      .exec (err, data) ->
        unless data.length
          Venue.update do
            id: venue.id
            $push: 'events': _event: event.id
          .exec (err, numAffected, rawResponse) ->
            return next err if err

    findAndCreateArtist = (event) ->
      Artist.findOne name: req.body.act
      .exec (err, artist) ->
        unless artist
          artist = new Artist do
            name: event.act
            permalink: event.act
            image: name: event.image.name
            events: [
              _event: event.id
            ]
          .save (err, artist) ->
            return next err if err
            addArtistToEvent(event, artist)
            findMatchingArtists(event, artist)

        addArtistToEvent(event, artist)
        findMatchingArtists(event, artist)

    addArtistToEvent = (event, artist) ->
      Event.update do
        id: event.id
        $set: _artist: artist.id
      .exec (err, numAffected, rawResponse) ->
        return next err if err

    findMatchingArtists = (event, artist) ->
      Artist.find events: $elemMatch: _event: event.id
      .exec (err, data) ->
        updateArtistEvents(event, artist) if not data.length

    updateArtistEvents = (event, artist) ->
      Artist.update do
        id: artist.id
        $push: 'events': _event: event.id
      .exec (err, numAffected, rawResponse) ->
        return next err if err

  destroy: (req, res, next) ->
    User.findOne _id: req.user
    .exec (err, usr) ->
      return next err if err
      return res.send 500 JSON.stringify 'You must be logged' if not usr

      Event.findOne id: req.params.id
      .exec (err, event) ->
        return next err if err
        return res.send 500 error: 'You are not authorized' if not usr._id.equals(event._user)

        removeTrack(event.id)
        updateArtist(event)
        removeEvent(event.id)

    removeEvent = (id) ->
      Event
        .remove id: id
        .exec (err, event) ->
          return next err if err

    removeTrack = (id) ->
      Track
        .remove _event: event.id
        .exec (err, event) ->
          return next err if err

    updateArtist = (event) ->
      Artist
        .update do
          name: event.act
          $pull: 'events': _event: event.id
        .exec (err, num, raw) ->
          return next err if err
