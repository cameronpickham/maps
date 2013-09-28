mongo   = require 'mongoskin'
request = require 'request'
config = require './config'

class Parser
  constructor: ->
    console.log 'hi i am a new parser'
    @db = mongo.db('localhost:27017/foursquare', { safe: true })
    @db.setMaxListeners(1000)
    @checkins = @db.collection('checkins')

  getPlaces: (cb) ->
    @checkins.find().toArray (err, data) ->
      cb(data)
  
  getTenRecent: (cb) ->
    @checkins.find().sort( {createdAt: -1}).limit(10).toArray (err, items) ->
      cb(items)
  
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
  
  pullData: (offset, cb) ->
    options =
      uri: 'https://api.foursquare.com/v2/users/self/checkins?oauth_token='
      qs:
        oauth_token: config.access_token
        v: 20130829
        limit: 250
        offset: offset
        beforeTimestamp: 9999999999
        afterTimestamp: 0

    request.get options, (err, res, body) =>
      body = JSON.parse body
      items = body.response.checkins.items
      return cb(items)

  scrape: ->
    offset = 0

    process = (items) =>
      return if items.length is 0

      for checkin in items
        place = @parsePlace(checkin)
        @updatePlaces(place)

      offset += 250
      @pullData(offset, process)

    @pullData(offset, process)

  updatePlaces: (place) ->
    @checkins.findOne { _id: place._id }, (err, item) =>
      if item?
        newCount = item.count+1
        createdAt = if item.createdAt < place.createdAt then place.createdAt else item.createdAt
        
        @checkins.update { _id: place._id }, { $set: { count: newCount, createdAt: createdAt } }, { }, (err, result) ->
          console.log "Updated!"
      else
        @checkins.insert place, { safe: true }, (err, result) ->
          console.log "Inserted!"
  
module.exports = new Parser()
