# Tracklist API
# Author: dev@auggod.io
# File: app/server/api/labels.ls

require! {
  '../models/label': Label  
}

module.exports =

  # CREATE label

  create: (req, res, next) ->
    label = new Label do
      name: req.body.name
    .save (err, label) ->
      return next err if err
      res.json label

  # READ labels

  list: (req, res, next) ->
    Label
      .find()
      .exec (err, labels) ->
        return next err if err
        res.json labels: labels 

  # READ label

  show: (req, res, next) ->

    Label
      .findOne permalink: req.params.permalink
      .populate do
        path: 'artists._artist'
      .exec (err, label) ->
        return next err if err
        res.json label
        

  # UPDATE label

  update: (req, res) ->

    Label.findOneAndUpdate permalink: req.params.permalink, req.body, upsert: true, (err, label) ->
      return next err if err
      res.sendStatus 200 .json label

  # DELETE label

  remove: (req, res) ->
