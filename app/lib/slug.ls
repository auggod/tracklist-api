latiniseJs = require('../config/latinise')

exports.setSlug = (slug) ->
  # Latinise
  # http://stackoverflow.com/questions/990904/javascript-remove-accents-in-strings
  Latinise = {}
  Latinise.latin_map = latiniseJs

  String::latinise = ->
    @replace /[^A-Za-z0-9\[\] ]/g, (a) ->
      Latinise.latin_map[a] or a

  String::latinize = String::latinise

  String::isLatin = ->
    this == @latinise()

  slug.split(' ').join('-').split('\'').join('-').toLowerCase().latinize()
