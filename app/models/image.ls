require! {
  mongoose  
  'mongoose-auto-increment': autoIncrement
  '../lib/slug'
}

Schema = mongoose.Schema
autoIncrement.initialize mongoose

ImageSchema = new Schema(
  __v:
    type: Number
    select: false
  id: type: Number
  path: type: String
  createdAt:
    type: Date
    default: Date.now)

ImageSchema.plugin autoIncrement.plugin,
  model: 'Image'
  field: 'id'
  startAt: 1
  incrementBy: 1

module.exports = mongoose.model('Image', ImageSchema)
