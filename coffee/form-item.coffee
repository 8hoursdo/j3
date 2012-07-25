do (j3) ->
  __getDefaultFormControlOption = (formItem, formItemOptions) ->
      parent : formItem
      datasource : formItemOptions.datasource
      id : formItemOptions.id
      name : formItemOptions.name
      width : formItemOptions.controlWidth
      height : formItemOptions.controlHeight
      fill : formItemOptions.controlFill
      on : formItemOptions.on

  j3.FormItem = FormItem = j3.cls j3.ContainerView,
    baseCss : 'form-item'

    templateBegin : j3.template '<div id="<%=id%>" class="<%=css%>"><label class="form-label" for="<%=controlId%>"><%=label%></label><div class="form-controls">'

    templateEnd : j3.template '<%if(helpText){%><span class="form-help"><%=helpText%><span><%}%></div></div>'

    onInit : (options) ->
      @_label = options.label
      @_inline = options.inline
      @_stacked = options.stacked
      @_compact = options.compact
      @_nolabel = options.nolabel
      @_isFirst = options.isFirst
      @_helpText = options.helpText

      if not options.controlId then options.controlId = j3.View.genId()
      @_controlId = options.controlId

      @_datasource = options.datasource

    getTemplateData : ->
      id : @id
      label : @_label
      css : @getCss() +
        (if @_inline then ' ' + @baseCss + '-inline' else '') +
        (if @_stacked then ' ' + @baseCss + '-stacked' else '') +
        (if @_compact then ' ' + @baseCss + '-compact' else '') +
        (if @_nolabel then ' ' + @baseCss + '-nolabel' else '') +
        (if @_isFirst then ' ' + @baseCss + '-first' else '')
      controlId : @_controlId
      helpText : @_helpText

    getDatasource : ->
      @_datasource

    createFormControl : (formItemOptions, formControlOptions) ->
      new formControlOptions.cls j3.ext(__getDefaultFormControlOption(this, formItemOptions), formControlOptions)

  j3.TextboxFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_textbox = @createFormControl options,
        cls : j3.Textbox
        text : options.value
        multiline : options.multiline
        type : options.type
        placeholder : options.placeholder

    textbox : ->
      @_textbox

    val : ->
      @_textbox.getText()

  j3.CheckboxFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_checkbox = @createFormControl options,
        cls : j3.Checkbox
        text : options.text
        value : options.value
        name : options.name
        valueName : options.valueName

    checkbox : ->
      @_checkbox

    val : ->
      @_checkbox.getValue()

  j3.DropdownListFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dropdownList = @createFormControl options,
        cls : j3.DropdownList
        items : options.items
        value : options.value
        placeholder : options.placeholder

    dropdownList : ->
      @_dropdownList

    val : ->
      @_dropdownList.getSelectedValue()

  j3.DropdownTreeFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dropdownTree = @createFormControl options,
        cls : j3.DropdownTree
        placeholder : options.placeholder
        treeOptions : options.treeOptions
        textName : options.textName
        itemsValName : options.itemsValName
        itemsTextName : options.itemsTextName
        itemsDatasource : options.itemsDatasource

    dropdownTree : ->
      @_dropdownTree

    val : ->
      @_dropdownTree.getSelectedValue()

  j3.DateSelectorFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dateSelector = @createFormControl options,
        cls : j3.DateSelector
        date : options.value
        placeholder : options.placeholder

    dateSelector : ->
      @_dateSelector

    val : ->
      @_dateSelector.getDate()

  j3.DateDurationFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_beginDateSelector = @createFormControl options,
        cls : j3.DateSelector
        date : options.beginValue
        placeholder : options.beginPlaceholder
        name : options.beginName
        mini : yes

      @_endDateSelector = @createFormControl options,
        cls : j3.DateSelector
        date : options.endValue
        placeholder : options.endPlaceholder
        name : options.endName
        mini : yes

    renderChildren : (sb) ->
      @_beginDateSelector.render sb
      sb.a '<span class="form-controls-connector">-</span>'
      @_endDateSelector.render sb

  j3.SwitchFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_switch = @createFormControl options,
        cls : j3.Switch
        checked : options.value

    switch : ->
      @_switch

    val : ->
      @_switch.getChecked()
