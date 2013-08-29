express  = require 'express'
passport = require 'passport'
mongo    = require 'mongodb'
FoursquareStrategy = require('passport-foursquare').Strategy
path     = require 'path'
routes   = require './routes'

MongoServer = mongo.Server
console.log MongoServer?
console.log mongo?
MongoDB     = mongo.Db
MongoBSON   = mongo.BSONPure

db_server   = new MongoServer('localhost', 27017, {auto_reconnect: true})
db          = new MongoDB('foursquare', db_server, {safe: true})

db.open (err, db) ->
  unless err
    console.log "Connected to the database"
    db.collection 'checkins', {strict: true}, (err, collection) ->
      console.log "No collection" if err

app = express()
app.configure ->
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.logger("dev")
  app.use express.static(path.join(__dirname, "public"))
  app.use express.errorHandler()  if "development" is app.get("env")
  app.use app.router

app.engine 'html', require('ejs').renderFile
app.set 'views', __dirname + '/views'

port = process.env.PORT or 3000

app.get '/', routes.index

app.listen port, ->
  console.log "Listening on port #{port}"
