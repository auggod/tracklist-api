require! {
  mongoose
  async
  lodash: _
}

exports.requiresInt = (req, res, next) ->
  return res.status(400).send(error: 'Param id must be an integer') if _.isNan(req.params.id)
  next!
