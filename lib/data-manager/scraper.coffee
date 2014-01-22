config  = require '../../config'
async   = require 'async'
request = require 'request'

Place = require '../models/place'

DATA_MANAGER = require './index'

module.exports =
  pullData: (offset, cb) ->
    options =
      uri: 'https://api.foursquare.com/v2/users/self/checkins?oauth_token='
      qs:
        oauth_token:     config.accessToken
        v:               20130829
        limit:           250
        offset:          offset
        beforeTimestamp: 9999999999
        afterTimestamp:  0

    request.get options, (err, res, body) ->
      return cb(err) if err

      body = JSON.parse(body)
      items = body.response.checkins.items
      cb(null, items)

  run: (cb) ->
    console.log 'Running...'

    Place.remove (err) =>
      offset = 0
      done   = false
      total  = 0

      fn = (cb) =>
        @pullData offset, (err, items) ->
          return cb(err) if err
          total += items.length
          
          unless items.length
            done = true
            return cb(null)

          each = (checkin, cb) ->
            DATA_MANAGER.handleNew(checkin, cb)

          async.eachSeries items, each, (err) ->
            return cb(err) if err
            offset += 250
            console.log 'Paging...', offset
            cb(null)

      test = -> not done

      async.doWhilst(fn, test, cb)
