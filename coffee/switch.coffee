do (j3) ->
  __switch_click = ->
    @checked !@checked()

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
      j3.on @el, 'click', this, __switch_click

      @setDatasource options.datasource

    checked : (checked) ->
      if j3.isUndefined checked then return @_checked

      if @_checked is !!checked then return

      j3.Dom.toggleCls @el, @baseCss + '-checked'
      @_checked = !!checked

      @updateData()

      @fire 'change', this

    onUpdateData : ->
      @_datasource.set @_name, @_checked

    onUpdateView : ->
      @checked @_datasource.get @_name

  j3.ext j3.Switch.prototype, j3.DataView

