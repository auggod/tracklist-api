require! {
  '../models/tag': Tag
}

module.exports =

  list: (req, res, next) ->
    Tag.find!
    .select '-id id text'
    .exec (err, tags) ->
      return next err if err
      res.json tags:tags

  show: (req, res) ->

  create: (req, res) ->

  update: (req, res) ->

  remove: (req, res) ->
