do (j3) ->
  __textbox_focus = ->
    @_updatingView = true
    @el.value = @_text
    j3.Dom.removeCls @el, @baseCss + '-empty'
    @_updatingView = false

    @fire 'focus', this

  __textbox_blur = ->
    @_updatingView = true
    if not @_text
      @el.value = @_placeholder
      j3.Dom.addCls @el, @baseCss + '-empty'
    @_updatingView = false

    @fire 'blur', this

  __textbox_keyup = (evt) ->
    __textbox_change.call this
    @fire 'keyup', this, keyCode : evt.keyCode()

  __textbox_change = ->
    if @_updatingView then return
    text = @el.value
    if @_text == text then return
    @_text = text
    j3.Dom.removeCls @el, @baseCss + '-empty'
    @updateData()
    @fire 'change', this

  j3.Textbox = j3.cls j3.View,
    baseCss : 'input'

    templateInput : j3.template '<input type="<%=type%>" id="<%=id%>" class="<%=css%>" name="<%=name%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readonly){%> readonly="readonly"<%}%> value="<%-text%>" />'
    templateTextarea : j3.template '<textarea id="<%=id%>" class="<%=css%>" name="<%=name%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readonly){%> readonly="readonly"<%}%> row="<%=row%>"><%-text%></textarea>'

    onInit : (options) ->
      @_text = options.text || ''
      @_primary = !!options.primary
      @_disabled = !!options.disabled
      @_readonly = !!options.readonly
      @_type = options.type || 'text'
      @_multiline = @_type == 'text' && !!options.multiline
      if @_multiline
        @_row = options.row || 3
      @_placeholder = options.placeholder || ''

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_disabled then ' disabled' else '') +
        (if @_multiline then ' input-multiline' else '') +
        (if !@_text then ' ' + @baseCss + '-empty')
      text : @_text || @_placeholder
      disabled : @_disabled
      readonly : @_readonly
      type : @_type
      name : @name
      row : @_row

    onRender : (buffer) ->
      if @_multiline then template = @templateTextarea else template = @templateInput
      buffer.append template @getTemplateData()
      return

    onCreated : (options) ->
      j3.on @el, 'focus', this, __textbox_focus

      j3.on @el, 'blur', this, __textbox_blur

      j3.on @el, 'keyup', this, __textbox_keyup

      j3.on @el, 'change', this, __textbox_change

      @setDatasource options.datasource

      return

    getText : ->
      @_text

    setText : (text) ->
      text = text || ''
      if @_text == text then return

      @_text = text

      @_updatingView = true
      if not @_text
        @el.value = @_placeholder
        j3.Dom.addCls @el, @baseCss + '-empty'
      else
        @el.value = @_text
        j3.Dom.removeCls @el, @baseCss + '-empty'
      @_updatingView = false

      @updateData()

      @fire 'change', this

    getDisabled : ->
      @_disabled

    setDisabled : (value) ->
      @_disabled = !!value
      @el.disabled = @_disabled
      j3.Dom.toggleCls @el, 'disabled'

    getReadOnly : ->
      @el.readOnly

    setReadOnly : (value) ->
      @el.readOnly = !!value

    focus : ->
      @el.focus()

    blur : ->
      @el.blur()

    onUpdateData : ->
      @_datasource.set @name, @_text

    onUpdateView : ->
      @setText @_datasource.get @name

  j3.ext j3.Textbox.prototype, j3.DataView

