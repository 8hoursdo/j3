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
        text : options.value
        multiline : options.multiline
        type : options.type
        name : options.name
        datasource : options.datasource
        fill : options.controlFill
        on : options.on
        parent : this

      @getChildren().insert @_textbox

    textbox : ->
      @_textbox

    val : ->
      @_textbox.getText()

  j3.DropdownListFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dropdownList = new j3.DropdownList
        items : options.items
        value : options.value
        name : options.name
        datasource : options.datasource
        fill : options.controlFill
        on : options.on
        parent : this

      @getChildren().insert @_dropdownList

    dropdownList : ->
      @_dropdownList

    val : ->
      @_dropdownList.getSelectedValue()

  j3.DateSelectorFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dateSelector = new j3.DateSelector
        date : options.value
        fill : options.controlFill
        name : options.name
        datasource : options.datasource
        on : options.on
        parent : this

      @getChildren().insert @_dateSelector

    dateSelector : ->
      @_dateSelector

    val : ->
      @_dateSelector.getDate()

  j3.SwitchFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_switch = new j3.Switch
        checked : options.value
        name : options.name
        datasource : options.datasource
        on : options.on
        parent : this

      @getChildren().insert @_switch

    switch : ->
      @_switch

    val : ->
      @_switch.checked()
