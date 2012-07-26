do (j3) ->
  __actionButton_click = (sender, args) ->
    if not sender.getPrimary()
      @_form.action sender.name, sender

  j3.FormActions = j3.cls j3.ContainerView,
    baseCss : 'form-actions'

    templateBegin : j3.template '<div id="<%=id%>" class="<%=css%>">'

    templateEnd : j3.template '</div>'

    onInit : (options) ->
      @_form = options.form
      @_form ?= options.parent
      @_align = options.align

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_align is 'right' then ' ' + @baseCss + '-right' else '') +
        (if @_align is 'left' then ' ' + @baseCss + '-left' else '') +
        (if @_align is 'center' then ' ' + @baseCss + '-center' else '')

    onCreateChild : (options) ->
      if not options.cls then options.cls = j3.Button

    onChildCreated : (child) ->
      child.on 'click', this, __actionButton_click
