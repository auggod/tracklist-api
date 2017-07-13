require! {
  mongoose  
  'mongoose-auto-increment': autoIncrement
  'mongoose-validator': validate
  '../lib/slug'
  'mongoosastic'
}

Schema = mongoose.Schema
autoIncrement.initialize mongoose

# Validations
# https://github.com/leepowellcouk/mongoose-validator

titleValidator = [ validate do
  validator: 'isLength'
  arguments: [3, 50]
  message: 'Title should be between 3 and 50 characters'
]

# Mongoose Schema

EventSchema = new Schema({
  __v:
    type: Number
    select: false
  id: Number
  _user:
    type: Schema.ObjectId
    ref: 'User'
  _artist:
    type: Number
    ref: 'Artist'
  venue: String
  title: String
  slug:
    type: String
    set: slug.setSlug
    default: 'slug'
  archived:
    type: Boolean
    default: false
  hidden:
    type: Boolean
    default: false
  text: String
  act: String
  type: String
  kind: String
  tags: []
  sources: [
    name: String
    key: String
    type: String
    uri: String
  ]
  date:
    type: Date
    default: Date.now
  startTime:
    type: Date
    default: Date.now
  endTime:
    type: Date
    default: Date.now
  featured:
    type: Boolean
    default: false
  active:
    type: Boolean
    default: false
  url: String
  images: [ { _image:
    type: Number
    ref: 'Image' } ]
  location:
    name: String
    cords:
      lng: Number
      lat: Number
  locations: [
    name: String
    cords:
      lng: Number
      lat: Number
  ]
  tracks: [
    _track:
      type: Number
      ref: 'Track'
    rank: type: Number
    metas:
      votes: type: Number
      favs: type: Number
    createdAt:
      type: Date
      default: Date.now
  ]
  image:
    name:
      type: String
      default: '1406209585528jduemdu8bh85mi'
    type: type: String
    size: Number
  updatedAt:
    type: Date
    default: Date.now
  createdAt:
    type: Date
    default: Date.now
}, strict: true)

# Methods

EventSchema.methods = {}

# Plugins

EventSchema.plugin autoIncrement.plugin,
  model: 'Event'
  field: 'id'
  startAt: 10
  incrementBy: 1

EventSchema.plugin(mongoosastic)

Event = mongoose.model('Event', EventSchema)

# TODO scynchronise items regularly
stream = Event.synchronize!
count = 0

stream.on 'data', (err, doc) ->
  count++
stream.on 'close', ->
  console.log 'indexed ' + count + ' documents!'
stream.on 'error', (err) ->
  console.log err

module.exports = Event
