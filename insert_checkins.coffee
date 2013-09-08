mongo         = require 'mongodb'
checkins_json = require './pulled_data'

MongoServer = mongo.Server
MongoDB     = mongo.Db
db_server   = new MongoServer('localhost', 27017, {auto_reconnect: true})
db          = new MongoDB('foursquare', db_server, {safe: true})

db.open (err, db) ->
  unless err
    console.log "Connected to the database"
    db.collection 'checkins', {strict: true}, (err, collection) ->
      console.log "Couldn't connect to collection" if err

      checkins = checkins_json.response.checkins.items

      for checkin in checkins
        do (checkin) ->
          place =
            _id: checkin.venue.id
            name: checkin.venue.name
            latLng: [checkin.venue.location.lat, checkin.venue.location.lng]
            count: checkin.venue.beenHere.count
          collection.findOne {_id: place._id}, (err, item) ->
            if item?
              collection.update {_id: place._id }, { $set: {count: place.count } }, (err, result) ->
                console.log "Updated!"
            else
              collection.insert place, {safe: true}, (err, result) ->
                return err if err
                console.log "Just inserted " + place.name + "!"

