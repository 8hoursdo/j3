j3.Switch = j3.cls j3.View,
  css : 'swt'

  template : j3.template '<div id="<%=id%>" class="<%=css%>"><a href="javascript:;"><span class="swt-on">YES</span><span class="swt-btn"></span><span class="swt-off">NO</span></a></div>'

  onInit : (options) ->
    @_checked = !!options.checked

  getViewData : ->
    id : @id
    css : @css +
      (if @_checked then ' ' +@css + '-checked' else '')

  onCreated : ->
    j3.on @el, 'click', this, ->
      @checked !@checked()

  checked : (checked) ->
    if j3.isUndefined checked then return @_checked

    if @_checked is !!checked then return

    j3.Dom.toggleCls @el, @css + '-checked'
    @_checked = !!checked

    @fire 'change', this
