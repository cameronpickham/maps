Place = require '../models/place'

module.exports =
  getPlaces: (count, cb) ->
    unless cb?
      cb    = count
      count = Infinity

    Place.find().sort('-createdAt').limit(count).exec(cb)

  summarizePlace: (checkin) ->
    { venue, createdAt }   = checkin
    return false unless venue
    { name, location, id } = venue
    latLng = [location.lat, location.lng]

    place =
      _id:       id
      name:      name
      latLng:    latLng
      createdAt: createdAt

  handleNew: (checkin, cb) ->
    summarized = @summarizePlace(checkin)
    return cb(null) unless summarized
    Place.createOrUpdate(summarized, cb)
