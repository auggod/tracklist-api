// Generated by LiveScript 1.4.0
(function(){
  var mongoose;
  mongoose = require('mongoose');
  exports.isAuthentificated = function(sessionId){
    return mongoose.connection.db.collection('sessions', function(err, collection){
      return collection.findOne({
        '_id': sessionId
      }, function(err, res){
        var session;
        return session = JSON.parse(res.session);
      });
    });
  };
}).call(this);
