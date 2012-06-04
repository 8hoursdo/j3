do (j3) ->

  j3.Toolbar = j3.cls j3.ContainerView,
    baseCss : 'toolbar'

    onCreateChild : (options, args) ->
      options.cls ?= j3.Button
      options.css ?= ''
      if args.first then options.css += ' first'
      if args.last then options.css += ' last'

