do(j3) ->
  __btn_click = (evt) ->
    @click()

    if @_linkButton and @_commandMode
      evt.stop()
    
  j3.Button = j3.cls j3.View,
    baseCss : 'btn'

    template : j3.template '<<%=linkButton?"a":"button"%> <%if(linkButton){%>href="<%=url%>"<%}else{%>type="<%=primary ? "submit" : "button"%>"<%}%> id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%> <%if(title){%> title="<%=title%>"<%}%>><%if(icon){%><i class="<%=icon%>"></i><%}%><%=text%></<%=linkButton?"a":"button"%>>'

    onInit : (options) ->
      @_text = options.text || ''
      @_tip = options.tip
      @_icon = options.icon
      @_primary = !!options.primary
      @_disabled = !!options.disabled
      @_active = !!options.active
      @_toggle = !!options.toggle

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
      title : @_tip
      icon : @_icon
      primary : @_primary
      disabled : @_disabled
      linkButton : @_linkButton
      url : @_url

    onCreated : ->
      j3.on @el, 'click', this, __btn_click

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
      @_active = !!value
      if @_active
        j3.Dom.addCls @el, 'active'
      else
        j3.Dom.removeCls @el, 'active'

      @fire (if @_active then 'active' else 'inactive'), this, active : @_active

    click : ->
      if @_disabled then return

      if @_toggle
        @setActive not @getActive()

      @fire 'click', this

    focus : ->
      @el.focus()

    blur : ->
      @el.blur()
      




