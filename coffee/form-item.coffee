do (j3) ->
  j3.FormItem = j3.cls j3.ContainerView,
    templateBegin : j3.template '<div id="<%=id%>" class="form-item"><label class="form-label"><%=label%></label><div class="form-controls">'

    templateEnd : j3.template '</div></div>'

    onInit : (options) ->
      @_label = options.label

    getViewData : ->
      id : @id
      label : @_label


  j3.TextboxFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_textbox = new j3.Textbox
        text : options.text
        multiline : options.multiline
        type : options.type
        fill : options.controlFill
        parent : this

      @getChildren().insert @_textbox


  j3.DropdownListFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dropdownList = new j3.DropdownList
        items : options.items
        value : options.value
        fill : options.controlFill
        parent : this

      @getChildren().insert @_dropdownList


  j3.DateSelectorFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dateSelector = new j3.DateSelector
        date : options.date
        fill : options.controlFill
        parent : this

      @getChildren().insert @_dateSelector
