DATA_MANAGER = require '../lib/data-manager'
SCRAPER      = require '../lib/data-manager/scraper'

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
    if req.body?
      console.log 'You got it right this time!'
      checkin = JSON.parse(req.body.checkin)
      DATA_MANAGER.handleNew checkin, (err) ->
        res.send 'Thx dude'
    else
      SCRAPER.run (err) ->
        console.log 'Foursquare gave you a bad POST so I scraped'
        res.send ':('
