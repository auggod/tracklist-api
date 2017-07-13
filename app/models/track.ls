require! {
  mongoose  
  'mongoose-auto-increment': autoIncrement
  'mongoose-validator': validate
  '../lib/slug'
}

Schema = mongoose.Schema
autoIncrement.initialize mongoose

#Validations

uriValidator = [ validate do
  validator: 'isLength'
  arguments: [
    20
    100
  ]
  message: 'Title should be between 3 and 50 characters'
]

TrackSchema = new Schema do
  id: Number
  events: [
    _event:
      type: Number
      ref: 'Event'
  ]
  source: String
  uri: String
  url: String
  createdAt:
    type: Date
    default: Date.now
  * strict: true

TrackSchema.plugin autoIncrement.plugin,
  model: 'Track'
  field: 'id'
  startAt: 1
  incrementBy: 1

module.exports = mongoose.model('Track', TrackSchema)
