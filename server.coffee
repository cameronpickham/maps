express  = require 'express'
passport = require 'passport'
mongo    = require 'mongodb'
path     = require 'path'
routes   = require './routes'
config   = require './config'

FoursquareStrategy = require('passport-foursquare').Strategy
MongoServer        = mongo.Server
MongoDB            = mongo.Db
db_server          = new MongoServer('localhost', 27017, {auto_reconnect: true})
db                 = new MongoDB('foursquare', db_server, {safe: true})

# Open collection
db.open (err, db) ->
  unless err
    console.log "Connected to the database"
    db.collection 'checkins', {strict: true}, (err, collection) ->
      console.log "Couldn't connect to collection" if err

# Configure
app = express()
app.configure ->
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.logger("dev")
  app.use express.static(path.join(__dirname, "public"))
  app.use express.errorHandler()  if "development" is app.get("env")
  app.use app.router
  app.use(passport.initialize())
  app.use(passport.session())
app.engine 'html', require('ejs').renderFile
app.set 'views', __dirname + '/views'

# Foursquare auth callback
CALLBACK_URL="https://maps.cameronpickham.com/auth/foursquare/callback"

# Passport configuration
passport.use(new FoursquareStrategy(
  {clientID: config.client_id, clientSecret: config.client_secret, callbackURL: CALLBACK_URL},
  (accessToken, refreshToken, profile, done) ->
    console.log "ACCESS! SUCCESS!"
    return done(null,"user")
))

# Port
port = process.env.PORT or 3000

# GET
app.get '/', routes.index

app.get '/auth/foursquare/callback', passport.authenticate 'foursquare', {successRedirect: '/', failureRedirect: '/'}, (req, res) ->
  res.redirect '/'

app.get '/checkins.json', (req, res) ->
  db.collection 'checkins', (err, collection) ->
    collection.find().toArray (err, data) ->
      res.json(data)

# POST
app.post '/', (req, res) ->
  checkin = JSON.parse(req.body.checkin)
  venue = checkin.venue
  lat_lng = [venue.location.lat, venue.location.lng]
  name = venue.name
  text = checkin.shout

  checkin =
    name: name
    lat_lng: lat_lng
    text: text

  db.collection 'checkins', (err, collection) ->
    collection.findOne { "lat_lng": lat_lng }, (err, item) ->
      if item?
        updateCheckin = collection.update {"lat_lng": lat_lng}, {$set: {text:text}}, (err, result) ->
          return err if err
          console.log "Updated a checkin!"
      else
        collection.insert checkin, {safe: true}, (err, result) ->
          return err if err
          console.log "Inserted a checkin!"

  res.send "Done!"

# Listen
app.listen port, ->
  console.log "Listening on port #{port}"
