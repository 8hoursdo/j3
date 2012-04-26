j3.Button = j3.cls j3.View,
  css : 'btn'

  template : j3.template '<button type="<%=primary ? "submit" : "button"%>" id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><%=text%></button>'

  onInit : (options) ->
    @_text = options.text || ''
    @_primary = !!options.primary
    @_disabled = !!options.disabled
    @_active = !!options.active
    @_toggle = !!options.toggle

  getViewData : ->
    id : @id
    css : @css +
      (if @_primary then ' ' +@css + '-primary' else '') +
      (if @_disabled then ' disabled' else '') +
      (if @_active then ' active' else '')
    text : @_text
    primary : @_primary
    disabled : @_disabled

  onCreated : ->
    j3.on @el, 'click', this, ->
      if @_toggle
        @setActive not @getActive()
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
    if @_disabled
      j3.Dom.addCls @el, 'disabled'
    else
      j3.Dom.removeCls @el, 'disabled'

  getActive : ->
    @_active

  setActive : (value) ->
    @_active = !!value
    if @_active
      j3.Dom.addCls @el, 'active'
    else
      j3.Dom.removeCls @el, 'active'




