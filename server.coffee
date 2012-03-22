require('zappa') 5230, ->
  @use 'bodyParser', 'methodOverride', @app.router

  @configure
    development: => @use errorHandler: {dumpExceptions: on}
    production: => @use 'errorHandler'

  @use @express.static __dirname

  @get '/': -> @response.redirect '/examples/index.htm'
