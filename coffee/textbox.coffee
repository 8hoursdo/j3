j3.Textbox = j3.cls j3.View,
  css : 'input'

  templateInput : _.template '<input type="<%=type%>" id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readonly){%> readonly="readonly"<%}%> value="<%-text%>" />'
  templateTextarea : _.template '<textarea id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readonly){%> readonly="readonly"<%}%>><%-text%></textarea>'

  onInit : (options) ->
    @_text = options.text || ''
    @_primary = !!options.primary
    @_disabled = !!options.disabled
    @_readonly = !!options.readonly
    @_type = options.type || 'text'
    @_multiline = @_type == 'text' && !!options.multiline

  getViewData : ->
    id : @id
    css : @css +
      (if @_disabled then ' disabled' else '')
    text : @_text
    disabled : @_disabled
    readonly : @_readonly
    type : @_type

  onRender : (buffer) ->
    if @_multiline then template = @templateTextarea else template = @templateInput
    buffer.append template @getViewData()
    return

  onCreated : ->
    @el.focus =>
      @fire 'focus', this

    @el.blur =>
      @fire 'blur', this

    @el.keyup =>
      text = @el.attr 'value'
      if @getText != text
        @_text = text
        @fire 'change', this

  getText : ->
    @_text

  setText : (text) ->
    text = text || ''
    if @_text == text then return

    @_text = text
    @el.attr 'value', @_text
    @fire 'change', this

  getDisabled : ->
    @_disabled

  setDisabled : (value) ->
    @_disabled = !!value
    @el.attr 'disabled', @_disabled
    @el.toggleClass 'disabled'

  getReadonly : ->
    @_readonly

  setDisabled : (value) ->
    @_readonly = !!value
    @el.attr 'readonly', @_readonly




