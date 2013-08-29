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
        name: checkin.venue.name
        lat_lng: [checkin.venue.location.lat, checkin.venue.location.lng]
        count: checkin.venue.beenHere.count
        createdAt: checkin.createdAt
      db.collection 'checkins', (err, collection) ->
        collection.insert place, {safe: true}, (err, result) ->
          return err if err
          console.log "Just inserted " + place.name + "!"
  console.log "Done"

