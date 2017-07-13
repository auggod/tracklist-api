require! {
  mongoose  
  crypto
  lodash: _
}

Schema = mongoose.Schema

authTypes = [
  'userapp'
  'soundcloud'
]

# User Schema

UserSchema = new Schema(
  __v:
    type: Number
    select: false
  _label:
    type: Number
    ref: 'Label'
  name:
    type: String
    default: ''
  email:
    type: String
    default: ''
  username:
    type: String
    default: ''
  lang:
    type: String
    default: 'en_EN'
  account_type:
    type: String
    default: 'user'
  role: type: String
  label:
    _label:
      type: Number
      ref: 'Label'
    name: type: String
  avatar:
    type: String
    default: ''
  image: name:
    type: String
    default: ''
  provider:
    type: String
    default: ''
  hashed_password:
    type: String
    default: ''
  salt:
    type: String
    default: ''
  authToken:
    type: String
    default: ''
  soundcloud: {})

###*
# Virtuals
###

UserSchema.virtual('password').set((password) ->
  @_password = password
  @salt = @makeSalt()
  @hashed_password = @encryptPassword(password)
  return
).get ->
  @_password

###*
# Validations
###

validatePresenceOf = (value) ->
  value and value.length

# the below 4 validations only apply if you are signing up traditionally
UserSchema.path('name').validate ((name) ->
  # if you are authenticating by any of the oauth strategies, don't validate
  if authTypes.indexOf(@provider) != -1
    return true
  name.length
), 'Name cannot be blank'
UserSchema.path('email').validate ((email) ->
  # if you are authenticating by any of the oauth strategies, don't validate
  if authTypes.indexOf(@provider) != -1
    return true
  email.length
), 'Email cannot be blank'
UserSchema.path('email').validate ((email, fn) ->
  User = mongoose.model('User')
  # Check only when it is a new user or when email field is modified
  if @isNew or @isModified('email')
    User.find(email: email).exec (err, users) ->
      fn err or users.length == 0
      return
  else
    fn true
  return
), 'Email already exists'
UserSchema.path('username').validate ((username) ->
  # if you are authenticating by any of the oauth strategies, don't validate
  if authTypes.indexOf(@provider) != -1
    return true
  username.length
), 'Username cannot be blank'
UserSchema.path('username').validate ((username, fn) ->
  User = mongoose.model('User')
  # Check only when it is a new user or when email field is modified
  if @isNew or @isModified('username')
    User.find(username: username).exec (err, users) ->
      fn err or users.length == 0
      return
  else
    fn true
  return
), 'Username already exists'
UserSchema.path('hashed_password').validate ((hashed_password) ->
  # if you are authenticating by any of the oauth strategies, don't validate
  if authTypes.indexOf(@provider) != -1
    return true
  hashed_password.length
), 'Password cannot be blank'

###*
# Pre-save hook
###

UserSchema.pre 'save', (next) ->
  if !@isNew
    return next()
  if !validatePresenceOf(@password) and authTypes.indexOf(@provider) == -1
    next new Error('Invalid password')
  else
    next()
  return

###*
# Methods
###

UserSchema.methods =
  authenticate: (plainText) ->
    @encryptPassword(plainText) == @hashed_password
  makeSalt: ->
    Math.round((new Date).valueOf() * Math.random()) + ''
  encryptPassword: (password) ->
    if !password
      return ''
    encrypred = undefined
    try
      encrypred = crypto.createHmac('sha1', @salt).update(password).digest('hex')
      return encrypred
    catch err
      return ''
    return

module.exports = mongoose.model 'User', UserSchema
