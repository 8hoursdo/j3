do (j3) ->
  j3.HtmlView = j3.cls j3.View,
    baseCss : ''

    onInit : (options) ->
      @_tagName = options.tagName
      @_selfClosing = options.selfClosing
      @_attributes = options.attributes
      @_innerHTML = options.innerHTML

    onRender : (sb) ->
      sb.a '<' + @_tagName

      sb.a ' id="' + @id + '"'

      css = @getCss()
      if css
        sb.a ' class="' + @css + '"'

      for attrName, attrValue of @_attributes
        sb.a ' ' + attrName + '="' + attrValue + '"'

      if @_selfClosing
        sb.a '/>'
        return

      sb.a '>'
      sb.a @_innerHTML || ''
      sb.a '</' + @_tagName + '>'
