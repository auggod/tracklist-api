require! {
  mongoose  
  'mongoose-auto-increment': autoIncrement
  '../lib/slug'
}

Schema = mongoose.Schema
autoIncrement.initialize mongoose

LabelSchema = new Schema(
  __v:
    type: Number
    select: false
  id: type: Number
  artists: [
    _artist:
      type: Number
      ref: 'Artist'
    name: type: String
  ]
  permalink:
    type: String
    set: slug.setSlug
  name: type: String
  text: type: String
  image: name:
    type: String
    default: 'default.jpg'
  createdAt:
    type: Date
    default: Date.now)
LabelSchema.plugin autoIncrement.plugin,
  model: 'Label'
  field: 'id'
  startAt: 1
  incrementBy: 1

module.exports = mongoose.model('Label', LabelSchema)
