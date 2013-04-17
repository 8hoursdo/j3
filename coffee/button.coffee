do(j3) ->
  __btn_click = (evt) ->
    @click()

    if @_linkButton and @_commandMode
      evt.stop()

  __btn_mouseover = (evt) ->
    __showTooltip.call this

  __btn_mouseout = (evt) ->
    __hideTooltip.call this

  __showTooltip = ->
    if not @_tip then return

    Dom = j3.Dom
    pos = Dom.position @el
    width = Dom.offsetWidth @el
    height = Dom.offsetHeight @el

    @_tooltip = j3.Tooltip.show
      content : @_tip
      encodeContent : yes
      pointAt :
        x : pos.left + (width / 2)
        y : pos.top + height

  __hideTooltip = ->
    if not @_tooltip then return
    @_tooltip.hide()
    
  j3.Button = j3.cls j3.View,
    baseCss : 'btn'

    template : j3.template '<<%=linkButton?"a":"button"%> <%if(linkButton){%>href="<%=url%>"<%}else{%>type="<%=primary ? "submit" : "button"%>"<%}%> id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><%if(icon){%><i class="<%=icon%>"></i><%}%><%=text%></<%=linkButton?"a":"button"%>>'

    onInit : (options) ->
      @_text = options.text || ''
      @_tip = options.tip
      @_icon = options.icon
      @_primary = !!options.primary
      @_disabled = !!options.disabled
      @_active = !!options.active
      @_toggle = options.toggle

      @_linkButton = !!options.linkButton
      @_url = options.url

      @_commandMode = options.commandMode

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_primary then ' btn-primary' else '') +
        (if @_disabled then ' disabled' else '') +
        (if @_active then ' active' else '')
      text : @_text
      icon : @_icon
      primary : @_primary
      disabled : @_disabled
      linkButton : @_linkButton
      url : @_url

    onCreated : (options) ->
      j3.on @el, 'click', this, __btn_click

      if not j3.UA.supportTouch
        j3.on @el, 'mouseover', this, __btn_mouseover
        j3.on @el, 'mouseout', this, __btn_mouseout

    getPrimary : ->
      @_primary

    getText : ->
      @_text

    setText : (text) ->
      @_text = text || ''
      @el.innerHTML = j3.htmlEncode @_text

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
      value = !!value

      if @_active is value then return

      @_active = value
      if @_active
        j3.Dom.addCls @el, 'active'
      else
        j3.Dom.removeCls @el, 'active'

      @fire (if @_active then 'active' else 'inactive'), this, active : @_active

    click : ->
      if @_disabled then return

      isActive = @getActive()
      if @_toggle is 'exclusive'
        @setActive not isActive
      else if @_toggle is 'radio' and not isActive
        @setActive true

      @fire 'click', this

    focus : ->
      @el.focus()

    blur : ->
      @el.blur()
      




