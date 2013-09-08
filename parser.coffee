mongo = require 'mongodb'

MongoServer = mongo.Server
MongoDB     = mongo.Db

class Parser
  constructor: ->
    @server = new MongoServer('localhost', 27017, { auto_reconnect: true } )
    @db     = new MongoDB('foursquare', @server, { safe: true })

    @db.open (err, db) ->
      unless err
        console.log "Connected to the database"
        db.collection "checkins", { strict: true }, (err, collection) ->
          console.log "Couldn't connect to collection" if err

  getPlaces: (cb) ->
    @db.collection "checkins", (err, collection) ->
      collection.find().toArray (err, data) ->
        cb data

  updatePlaces: (place) ->
    @db.collection "checkins", (err, collection) ->
      collection.findOne { _id: place._id }, (err, item) ->
        if item?
          collection.update { _id: place._id }, { $set: { count: place.count } }, (err, result) ->
            console.log "Updated!"
        else
          collection.insert place, { safe: true }, (err, result) ->
            console.log "Inserted!"
  
  parsePlace: (checkin) ->
    { venue } = checkin
    { name, location, id } = venue
    { beenHere } = venue if venue.beenHere?
    latLng = [location.lat, location.lng]

    return place =
      _id: id
      name: name
      latLng: latLng
      count: beenHere?.count

module.exports = new Parser()
