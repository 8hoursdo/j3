do (j3) ->

  _theApp = null

  j3.app = -> _theApp

  __location_change = (args) ->
    @_router.handle args.path
  
  j3.Application = j3.cls
    ctor : (options) ->
      _theApp = @
      @_router = new j3.Router routes : options.routes

      @onLoad && @onLoad()
      return

    start : ->
      j3.Location.on 'change', this, __location_change
      j3.Location.start()
      
