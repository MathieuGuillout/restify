A small web server to display / update / add / remove entities

We load the configuration file

    path = process.cwd() 
    program.config ?= "#{path}/config.yaml"
    params = require program.config

We first create a web server

    app = express()

We apply the needed middlewares

    app.configure () ->
      app.use express.static "#{__dirname}/public"
      app.use express.cookieParser()
      app.use connect.bodyParser()
      app.use app.router



And finally, we start the web server

    params.web_server ?= {}
    params.web_server.port ?= 3001
    app.listen params.web_server.port
