j3.Button = j3.cls j3.View,
  css : 'btn'

  template : _.template '<button type="<%=primary ? "submit" : "button"%>" id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><%=text%></button>'

  onInit : (options) ->
    @_text = options.text || ''
    @_primary = !!options.primary
    @_disabled = !!options.disabled

  getViewData : ->
    id : @id
    css : @css +
      (if @_primary then ' ' +@css + '-primary' else '') +
      (if @_disabled then ' disabled' else '')
    text : @_text
    primary : @_primary
    disabled : @_disabled

  onCreated : ->
    j3.on @el, 'click', =>
      @fire 'click', this

  getText : ->
    @_text

  setText : (text) ->
    @_text = text || ''
    @el.innerHTML = @_text

  getDisabled : ->
    @_disabled

  setDisabled : (value) ->
    @_disabled = !!value
    @el.disabled = @_disabled
    j3.Dom.toggleCls @el, 'disabled'




