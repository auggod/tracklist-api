module.exports = do
  development:
    root: require('path').normalize(__dirname + '/..')
    app: name: 'Tracklist'
    db: 'mongodb://localhost/track'
    soundcloud:
      clientID: '7ccdc45fd79d9d019b9079f3e98d0a86'
      clientSecret: 'efffb3c141522dcb42379c0c728a1a5e'
      callbackURL: 'http://auggod-track.herokuapp.com/auth/soundcloud/callback'
  test: {}
  production:
    root: require('path').normalize(__dirname + '/..')
    app: name: 'Tracklist'
    db: 'mongodb://localhost/track'
    soundcloud:
      clientID: '7ccdc45fd79d9d019b9079f3e98d0a86'
      clientSecret: 'efffb3c141522dcb42379c0c728a1a5e'
      callbackURL: 'http://localhost:3001/auth/soundcloud/callback'
