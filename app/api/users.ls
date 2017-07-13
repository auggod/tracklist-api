require! {
  mongoose
  lodash: _
  '../lib/utils'
  '../models/label': Label
  '../models/user': User
}

module.exports =

  create: (req, res, next) ->
    user = new User(req.body)
    user.provider = 'local'
    user.save (err) ->
      if err
        return res.send(500, JSON.stringify(errors: utils.errors(err.errors)))
      # manually login the user once successfully signed up
      req.logIn user, (err) ->
        return next err if err
        res.send 200, JSON.stringify('Successfully logged in')

  #READ user

  show: (req, res) ->

    findUser = (userId) ->
      User.findOne(_id: userId).select('username role email name avatar lang label account_type').exec (err, user) ->
        res.json user

    console.log req.session
    mongoose.connection.db.collection 'sessions', (err, collection) ->
      collection.findOne { '_id': req.headers['x-tracklist-session-id'] }, (err, res) ->
        session = JSON.parse(res.session)
        console.log session.passport.user
        findUser session.passport.user

  # LIST users

  list: (req, res) ->
    unless req.session.passport.user
      return res.status(401).send(error: 'User is not logged in')
    perPage = 10
    page = if req.param('page') > 0 then req.param('page') else 0
    User.find({}).select('username role email name avatar lang label account_type').skip(perPage * page).exec (err, users) ->
      User.count().exec (err, count) ->
        res.json do
          users: users
          page: page
          pages: count / perPage

  # UPDATE user
  update: (req, res, next) ->
    User
      .findOne username: req.params.username
      .select 'username email name avatar lang label account_type'
      .exec (err, user) ->
        return next err if err
        if req.body.label
          console.log req.body.label.name
          #TODO

  remove: (req, res, next) ->

    User
      .findOne username: req.params.username
      .exec (err, user) ->
        return next err if err
        user.remove (err) ->
          if err
            return res.json(err)
          res.json user

  # Auth

  login: (req, res) ->
    res.send()

  signin: (req, res) ->

  #Auth callback

  authCallback: @login

  auth: (req, res, next) ->

    User
      .findOne _id: req.session.passport.user
      .exec (err, usr) ->
        return next err if err
        unless usr
          return res.send(401, message: 'User is not logged')
        if usr
          return res.json do
            sessionId: req.sessionID
            userId: usr._id
            userRole: usr.role
            username: usr.username

  #Logout

  logout: (req, res) ->
    req.logout()
    res.redirect '/login'

  #Session

  session: @login
