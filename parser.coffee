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
          newCount = item.count+1
          collection.update { _id: place._id }, { $set: { count: newCount } }, (err, result) ->
            console.log "Updated!"
        else
          collection.insert place, { safe: true }, (err, result) ->
            console.log "Inserted!"
  
  parsePlace: (checkin) ->
    { venue, createdAt } = checkin
    { name, location, id, beenHere } = venue
    latLng = [location.lat, location.lng]

    return place =
      _id: id
      name: name
      createdAt: createdAt
      latLng: latLng
      count: beenHere?.count or 1

module.exports = new Parser()
