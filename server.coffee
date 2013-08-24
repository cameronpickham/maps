express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")

app = express()

app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.engine "html", require("ejs").renderFile

app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))
app.use express.errorHandler()  if "development" is app.get("env")

app.get "/", routes.index

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
