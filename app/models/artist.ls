require! {
  mongoose
  'mongoose-auto-increment': autoIncrement
  '../lib/slug'
  'mongoosastic'
}

Schema = mongoose.Schema
autoIncrement.initialize mongoose

ArtistSchema = new Schema({
  id: type: Number
  events: [
    _event:
      type: Number
      ref: 'Event'
  ]
  shortBio: String
  longBio: String
  text:
    short: String
    long: String
  name:
    type: String
  spellings: []
  links: [
    url: String
    name: String
  ]
  # Is a list of labels
  labels: []
  # Is the main/current label
  label:
    name: type: String
  # Main image
  image: name: type: String
  hidden:
    type: Boolean
    default: false
  # List of images
  images: [
    _image:
      type: Number
      ref: 'Image'
  ]
  slug:
    type: String
    set: slug.setSlug
    default: 'slug'
  updatedAt:
    type: Date
    default: Date.now
  createdAt:
    type: Date
    default: Date.now
}, strict: true)

ArtistSchema.plugin(mongoosastic)

ArtistSchema.plugin autoIncrement.plugin,
  model: 'Artist'
  field: 'id'
  startAt: 1
  incrementBy: 1

Artist = mongoose.model('Artist', ArtistSchema)

stream = Artist.synchronize!
count = 0

ArtistSchema.pre 'save', (next) ->
  self = this
  Artist.find name: @name, (err, docs) ->
    if not docs.length
      next!
    else
      console.log self
      next!

ArtistSchema.pre 'update', (next) ->
  now = new Date
  @updatedAt = now
  unless @createdAt
    @createdAt = now
  next!
  return

module.exports = mongoose.model('Artist', ArtistSchema)
