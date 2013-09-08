express  = require 'express'
passport = require 'passport'
mongo    = require 'mongodb'
path     = require 'path'
routes   = require './routes'
config   = require './config'
parser   = require './parser'

FoursquareStrategy = require('passport-foursquare').Strategy

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
  parser.getPlaces (data) ->
    res.json(data)

# POST
app.post '/', (req, res) ->
  checkin = JSON.parse(req.body.checkin)
  place = parser.parsePlace(checkin)
  parser.updatePlaces(place)
  res.send "Thank you!"

# Listen
app.listen port, ->
  console.log "Listening on port #{port}"
