do (j3) ->
  __el_keypress = (evt) ->
    if evt.keyCode() is 32
      @click()
      evt.stop()

  j3.Switch = j3.cls j3.View,
    baseCss : 'swt'

    template : j3.template '<div id="<%=id%>" class="<%=css%>"><a href="javascript:;"><span class="swt-on">YES</span><span class="swt-btn"></span><span class="swt-off">NO</span></a></div>'

    onInit : (options) ->
      @_name = options.name
      @_checked = !!options.checked

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_checked then ' ' + @baseCss + '-checked' else '')

    onCreated : (options) ->
      j3.on @el, 'click', this, @click
      j3.on @el, 'keypress', this, __el_keypress

      @setDatasource options.datasource

    getChecked : ->
      @_checked

    setChecked : (checked) ->
      if @_checked is !!checked then return

      j3.Dom.toggleCls @el, @baseCss + '-checked'
      @_checked = !!checked

      @updateData()

      @fire 'change', this

    click : ->
      @setChecked !@getChecked()

    onUpdateData : ->
      @_datasource.set @_name, @_checked

    onUpdateView : ->
      @setChecked @_datasource.get @_name

  j3.ext j3.Switch.prototype, j3.DataView

