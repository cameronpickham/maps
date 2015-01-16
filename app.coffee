express  = require 'express'
passport = require 'passport'
coffee   = require 'coffee-middleware'
bodyParser = require 'body-parser'

{ clientId, clientSecret } = require './config'

FoursquareStrategy = require('passport-foursquare').Strategy

CALLBACK_URL = 'https://maps.cameronpickham.com/auth/foursquare/callback'
PORT = process.env.PORT || 3000

app = express()


coffeeOptions =
  bare:   false
  src:    __dirname + '/assets'
  force:  true
  prefix: '/assets'

app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'

app.use(passport.initialize())
app.use(passport.session())

app.use(coffee(coffeeOptions))
app.use(express.static(__dirname + '/assets'))
app.use(express.static(__dirname + '/public'))
#app.use(express.favicon())
#app.use(express.logger('dev'))
#app.use(express.json())
#app.use(express.urlencoded())
#app.use(express.methodOverride())
#app.use(express.cookieParser())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))
require('./routes')(app, passport)

passport.use(new FoursquareStrategy(
  { clientID: clientId, clientSecret, callbackURL: CALLBACK_URL },
  (accessToken, refreshToken, profile, done) ->
    done(null, 'user')
))

app.listen PORT, ->
  console.log "Listening on port #{PORT}"
