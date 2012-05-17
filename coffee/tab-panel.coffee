do (j3) ->
  j3.TabPanel = j3.cls j3.ContainerView,
    baseCss : 'tab-pnl'

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @getActive() then ' tab-pnl-active' else '')

    onInit : (options) ->
      @_title = options.title
      @_name = options.name

    onCreated : ->
      @elTrigger = j3.$ @id + '-trigger'

    setActive : ->
      @parent.setActive this

    getActive : ->
      @parent.getActive() is this

    getTitle : ->
      @_title

    getName : ->
      @_name
