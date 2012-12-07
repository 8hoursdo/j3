do (j3) ->
  __textbox_focus = ->
    @_updatingView = true
    @_elInput.value = @_text
    j3.Dom.removeCls @_elInput, @baseCss + '-empty'
    @_updatingView = false

    @fire 'focus', this

  __textbox_blur = ->
    @_updatingView = true
    if not @_text
      j3.Dom.addCls @_elInput, @baseCss + '-empty'
    @_updatingView = false

    @fire 'blur', this

  __textbox_keyup = (evt) ->
    __textbox_change.call this
    @fire 'keyup', this, keyCode : evt.keyCode()

  __textbox_change = ->
    if @_updatingView then return
    text = @_elInput.value
    if @_text == text then return
    @_text = text
    j3.Dom.removeCls @_elInput, @baseCss + '-empty'

    if j3.UA.ie
      __refreshPlaceholder.call this

    if @_multiline and @_autoHeight
      __adjustHeight.call this

    @updateData()
    @fire 'change', this

  __refreshPlaceholder = ->
    @_elInput.placeholder = ''

    if @_text and @_placeholder and @_elPlaceholder
      j3.Dom.hide @_elPlaceholder
      return
  
    # placeholder为空，隐藏placeholder元素
    if not @_placeholder
      if @_elPlaceholder
        j3.Dom.hide @_elPlaceholder

    else
      if not @_elPlaceholder
        @_elPlaceholder = document.createElement 'span'
        @_elPlaceholder.className = 'input-placeholder'
        @el.appendChild @_elPlaceholder
        j3.on @_elPlaceholder, 'click', this, (evt) ->
          @_elInput.focus()
      else
        j3.Dom.show @_elPlaceholder

      @_elPlaceholder.innerHTML = j3.htmlEncode @_placeholder

  __adjustHeight = ->
    elInput = @_elInput
    if elInput.scrollHeight > elInput.offsetHeight - 2
      if not @_originalHeight
        @_originalHeight = j3.Dom.height elInput
      j3.Dom.height elInput, elInput.scrollHeight + 2
    else if @_originalHeight
      height = j3.Dom.height elInput
      if height > @_originalHeight
        j3.Dom.height elInput, height - 20
        __adjustHeight.call this
      

  j3.Textbox = j3.cls j3.View,
    baseCss : 'input'

    templateInput : j3.template '<div id="<%=id%>" class="input-ctnr"><input type="<%=type%>" class="<%=css%>" name="<%=name%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readOnly){%> readonly="readonly"<%}%><%if(placeholder){%> placeholder="<%-placeholder%>"<%}%> value="<%-text%>" /></div>'
    templateTextarea : j3.template '<div id="<%=id%>" class="input-ctnr"><textarea class="<%=css%>" name="<%=name%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readOnly){%> readonly="readonly"<%}%><%if(placeholder){%> placeholder="<%-placeholder%>"<%}%> row="<%=row%>"><%-text%></textarea></div>'

    onInit : (options) ->
      @_text = options.text || ''
      @_primary = !!options.primary
      @_disabled = !!options.disabled
      @_readOnly = !!options.readOnly
      @_type = options.type || 'text'
      @_multiline = @_type == 'text' && !!options.multiline
      if @_multiline
        @_row = options.row || 3
      @_autoHeight = !!options.autoHeight
      @_placeholder = options.placeholder || ''

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_disabled then ' disabled' else '') +
        (if @_multiline then ' input-multiline' else '') +
        (if !@_text then ' ' + @baseCss + '-empty')
      text : @_text
      disabled : @_disabled
      readOnly : @_readOnly
      type : @_type
      name : @name
      row : @_row
      placeholder : @_placeholder

    onRender : (buffer) ->
      if @_multiline then template = @templateTextarea else template = @templateInput
      buffer.append template @getTemplateData()
      return

    onCreated : (options) ->
      @_elInput = @el.firstChild

      j3.on @_elInput, 'focus', this, __textbox_focus

      j3.on @_elInput, 'blur', this, __textbox_blur

      j3.on @_elInput, 'keyup', this, __textbox_keyup

      j3.on @_elInput, 'change', this, __textbox_change

      @setDatasource options.datasource
      
      if j3.UA.ie and @_placeholder
        __refreshPlaceholder.call this

      return

    getText : ->
      @_text

    setText : (text) ->
      text = text || ''
      if @_text == text then return

      @_text = text

      @_updatingView = true
      if not @_text
        @_elInput.value = ''
        j3.Dom.addCls @_elInput, @baseCss + '-empty'
      else
        @_elInput.value = @_text
        j3.Dom.removeCls @_elInput, @baseCss + '-empty'

      if j3.UA.ie
        __refreshPlaceholder.call this

      if @_multiline and @_autoHeight
        __adjustHeight.call this

      @_updatingView = false

      @updateData()

      @fire 'change', this

    getDisabled : ->
      @_disabled

    setDisabled : (value) ->
      @_disabled = !!value
      @_elInput.disabled = @_disabled
      j3.Dom.toggleCls @_elInput, 'disabled'

    getReadOnly : ->
      @_elInput.readOnly

    setReadOnly : (value) ->
      @_elInput.readOnly = !!value

    focus : ->
      if @getDisabled() then return false

      @_elInput.focus()
      @_elInput.select -1, -1
      true

    blur : ->
      @_elInput.blur()

    getPlaceholder : ->
      @_placeholder

    setPlaceholder : (value) ->
      @_placeholder = value || ''
      if j3.UA.ie
        __refreshPlaceholder.call this
      else
        @_elInput.placeholder = @_placeholder

    onUpdateData : ->
      @_datasource.set @name, @_text

    onUpdateView : (datasource, eventName, args) ->
      if args and args.changedData and not args.changedData.hasOwnProperty @name then return
      @setText datasource.get @name

    onSetWidth : (width) ->
      j3.Dom.offsetWidth @_elInput, width

    onSetHeight : (height) ->
      j3.Dom.offsetHeight @_elInput, height

  j3.ext j3.Textbox.prototype, j3.DataView

