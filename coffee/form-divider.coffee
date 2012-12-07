do (j3) ->
  j3.FormDivider = j3.cls j3.View,
    baseCss : 'form-divider'

    template : j3.template '<div id=<%=id%> class=<%=css%>></div>'
