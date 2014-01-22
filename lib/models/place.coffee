mongoose = require('mongoose')
Schema   = mongoose.Schema

db = mongoose.createConnection("mongodb://localhost:27017/foursquare")

schema = new Schema {
  _id:       { type: String, index: true }
  name:      { type: String, index: true }
  latLng:    { type: Array,  index: true }
  count:     { type: Number, index: true, default: 1 }
  createdAt: { type: String, index: true }
}, { collection: 'places' }

schema.statics =
  createOrUpdate: (summarized, cb) ->
    params =
      _id: summarized._id

    @findOne params, (err, item) =>
      return cb(err) if err

      if item
        item.count++
        
        if item.createdAt < summarized.createdAt
          item.createdAt = summarized.createdAt
        
        item.save(cb)
      else
        @create(summarized, cb)

schema.methods = {}

Place          = db.model('Place', schema)
module.exports = Place
