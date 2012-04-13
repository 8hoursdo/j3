do (j3) ->
  __actionButton_click = (sender, args) ->
    @_form.action sender.name, sender

  j3.FormActions = j3.cls j3.ContainerView,
    templateBegin : j3.template '<div id="<%=id%>" class="form-actions">'

    templateEnd : j3.template '</div>'

    onInit : (options) ->
      @_form = options.form

    onChildCreated : (child) ->
      child.on 'click', this, __actionButton_click
