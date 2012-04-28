do (j3) ->
  __actionButton_click = (sender, args) ->
    @_form.action sender.name, sender

  j3.FormActions = j3.cls j3.ContainerView,
    baseCss : 'form-actions'

    templateBegin : j3.template '<div id="<%=id%>" class="<%=css%>">'

    templateEnd : j3.template '</div>'

    onInit : (options) ->
      @_form = options.form

    onChildCreated : (child) ->
      child.on 'click', this, __actionButton_click
