do (j3) ->
  j3.Navbar = j3.cls j3.ContainerView,
    baseCss : 'navbar'

    onInit : (options) ->
      @fixedTop = !!options.fixedTop

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @fixedTop then ' ' + @baseCss + '-fixed-top' else '')
