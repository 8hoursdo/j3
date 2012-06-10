do (j3) ->
  __el_keypress = (evt) ->
    if evt.keyCode() is 32
      @click()
      evt.stop()
    
  j3.Checkbox = j3.cls j3.View,
    baseCss : 'chk'

    template : j3.template '<a id="<%=id%>" class="<%=css%>" href="javascript:;"><i></i><span><%-text%></span></a>'

    onInit : (options) ->
      @_text = options.text || ''
      @_disabled = !!options.disabled
      @_checked = !!options.checked
      @_value = options.value
      @_valueName = options.valueName

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_disabled then ' ' + @baseCss + '-disabled' else '') +
        (if @_checked then ' ' + @baseCss + '-checked' else '')
      text : @_text

    onCreated : (options) ->
      j3.on @el, 'click', this, @click
      j3.on @el, 'keypress', this, __el_keypress

      @_elText = j3.Dom.byIndex @el, 1

      @setDatasource options.datasource

    getText : ->
      @_text

    setText : (text) ->
      @_text = text || ''
      @_elText.innerHTML = j3.htmlEncode @_text

    getValue : ->
      @_value

    setValue : (value) ->
      @_value = value

      if @_checked && @_valueName then @updateData()

    getDisabled : ->
      @_disabled

    setDisabled : (value) ->
      @_disabled = !!value
      css = @baseCss + '-disabled'
      if @_disabled
        j3.Dom.addCls @el, css
      else
        j3.Dom.removeCls @el, css

    getChecked : ->
      @_checked

    setChecked : (value) ->
      value = !!value
      if @_checked is value then return

      @_checked = value
      css = @baseCss + '-checked'
      if @_checked
        j3.Dom.addCls @el, css
      else
        j3.Dom.removeCls @el, css

      @fire 'change', this, checked : @_checked
      @updateData()

    click : ->
      if not @getDisabled()
        @setChecked !@getChecked()

    focus : ->
      @el.focus()

    blur : ->
      @el.blur()

    onUpdateData : (datasource) ->
      checked = @getChecked()
      if @name
        datasource.set @name, checked
      if @_valueName
        datasource.set @_valueName, if checked then @_value else null

    onUpdateView : (datasource) ->
      if @name
        @setChecked datasource.get @name
      
  j3.ext j3.Checkbox.prototype, j3.DataView
