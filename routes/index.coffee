DATA_MANAGER = require '../lib/data-manager'

module.exports = (app, passport) ->
  app.get '/', (req, res, next) ->
    DATA_MANAGER.getPlaces 10, (err, data) ->
      res.render 'index', { places: data }

  app.get '/auth/foursquare/callback', passport.authenticate 'foursquare', { successRedirect: '/', failureRedirect: '/' }, (req, res, next) ->
    res.redirect '/'

  app.get '/places.json', (req, res) ->
    DATA_MANAGER.getPlaces (err, data) ->
      res.json(data)

  app.post '/', (req, res) ->
    checkin = JSON.parse(req.body.checkin)
    DATA_MANAGER.handleNew checkin, (err) ->
      res.send 'Thx dude'
