do(j3) ->
  j3.BoxWithArrow = j3.cls j3.ContainerView,
    baseCss : 'box-with-arrow'

    templateBegin : j3.template '<div id="<%=id%>" class="<%=css%>"><div class="box-arrow"></div><div class="box">'

    templateEnd : j3.template '</div></div>'

    onInit : (options) ->
      @_placement = options.placement || 'top'

    getTemplateData : ->
      id : @id
      css : @getCss() + ' ' + @baseCss + '-' + @_placement

    onCreated : (options) ->
      @elBody = j3.Dom.byIndex @el, 1

