require! {
  mongoose  
  'mongoose-auto-increment': autoIncrement
  '../lib/slug'
  'mongoosastic'
}

Schema = mongoose.Schema
autoIncrement.initialize mongoose

VenueSchema = new Schema do
  id: Number
  events: [ 
    _event:
      type: Number
      ref: 'Event'
  ]
  artists: [
    _artist:
      type: Number
      ref: 'Artist'
  ]
  permalink:
    type: String
    set: slug.setSlug
  name: String
  title: String
  image: name:
    type: String
    default: 'default.jpg'
  kind:
    type: String
    default: 'festival'
  * strict: true

VenueSchema.methods = {}

VenueSchema.plugin(mongoosastic)

VenueSchema.plugin autoIncrement.plugin,
  model: 'Venue'
  field: 'id'
  startAt: 1
  incrementBy: 1

Venue = mongoose.model('Venue', VenueSchema)

stream = Venue.synchronize!
count = 0

module.exports = mongoose.model('Venue', VenueSchema)
