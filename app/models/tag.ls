require! {
  mongoose  
  'mongoose-auto-increment': autoIncrement
}

Schema = mongoose.Schema
autoIncrement.initialize mongoose

###*
# Mongoose Schema
###

TagSchema = new Schema(
  __v:
    type: Number
    select: false
  id: Number
  count:
    type: Number
    default: 1
  text: String)
TagSchema.plugin autoIncrement.plugin,
  model: 'Tag'
  field: 'id'
  startAt: 1
  incrementBy: 1

module.exports = mongoose.model('Tag', TagSchema)
