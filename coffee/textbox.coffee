do (j3) ->
  __textbox_focus = ->
    @fire 'focus', this

  __textbox_blur = ->
    @fire 'blur', this

  __textbox_change = ->
    @setText @el.value

  j3.Textbox = j3.cls j3.View,
    css : 'input'

    templateInput : j3.template '<input type="<%=type%>" id="<%=id%>" class="<%=css%>" name="<%=name%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readonly){%> readonly="readonly"<%}%> value="<%-text%>" />'
    templateTextarea : j3.template '<textarea id="<%=id%>" class="<%=css%>" name="<%=name%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readonly){%> readonly="readonly"<%}%>><%-text%></textarea>'

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
      name : @name

    onRender : (buffer) ->
      if @_multiline then template = @templateTextarea else template = @templateInput
      buffer.append template @getViewData()
      return

    onCreated : (options) ->
      j3.on @el, 'focus', this, __textbox_focus

      j3.on @el, 'blur', this, __textbox_blur

      j3.on @el, 'keyup', this, __textbox_change

      j3.on @el, 'change', this, __textbox_change

      @setDatasource options.datasource

      return

    getText : ->
      @_text

    setText : (text) ->
      text = text || ''
      if @_text == text then return

      @_text = text
      @el.value = @_text

      @updateData()

      @fire 'change', this

    getDisabled : ->
      @_disabled

    setDisabled : (value) ->
      @_disabled = !!value
      @el.disabled = @_disabled
      j3.Dom.toggleCls @el, 'disabled'

    getReadonly : ->
      @_readonly

    setReadonly : (value) ->
      @_readonly = !!value
      @el.readonly = @_readonly

    onUpdateData : ->
      @_datasource.set @name, @_text

    onUpdateView : ->
      @setText @_datasource.get @name

  j3.ext j3.Textbox.prototype, j3.DataView

