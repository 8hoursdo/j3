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

      options.datasource ?= @parent.getDatasource()
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

    renderBegin : (sb, templateData) ->
      sb.a '<div id="' + templateData.id + '" class="' + templateData.css + '">'
      sb.a '<label class="form-label" for="' + @_controlId + '">'
      @renderLabelContent sb
      sb.a '</label>'

      sb.a '<div class="form-controls">'
      return
        
    renderEnd : (sb, templateData) ->
      if @_helpText
        sb.a '<div class="form-help">'
        sb.a @_helpText
        sb.a '</div>'

      sb.a '</div>' # end of form-controls
      sb.a '</div>' # end of form-item
      return

    renderLabelContent : (sb) ->
      sb.e @_label
      return

    onCreated : ->
      @elBody = j3.Dom.byIndex @el, 1

    getDatasource : ->
      @_datasource

    createFormControl : (formItemOptions, formControlOptions) ->
      new formControlOptions.cls j3.ext(__getDefaultFormControlOption(this, formItemOptions), formControlOptions)

    setDisabled : ->

    getControlId : ->
      @_controlId

  j3.TextboxFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_textbox = @createFormControl options,
        cls : j3.Textbox
        id : @getControlId()
        text : options.value
        multiline : options.multiline
        type : options.type
        placeholder : options.placeholder
        disabled : options.disabled
        autoHeight : options.controlAutoHeight

    textbox : ->
      @_textbox

    val : ->
      @_textbox.getText()

    focus : ->
      @_textbox.focus()

    setDisabled : (value) ->
      @_textbox.setDisabled value

  j3.CheckboxFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_checkbox = @createFormControl options,
        cls : j3.Checkbox
        id : @getControlId()
        text : options.text
        value : options.value
        bindingMode : options.bindingMode
        disabled : options.disabled

    checkbox : ->
      @_checkbox

    val : ->
      @_checkbox.getValue()

    setDisabled : (value) ->
      @_checkbox.setDisabled value

  j3.CheckboxListFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_checkboxList = @createFormControl options,
        cls : j3.CheckboxList
        id : @getControlId()
        items : options.items
        itemsDatasource : options.itemsDatasource
        itemInline : options.listItemInline
        itemWidth : options.listItemWidth
        bindingMode : options.bindingMode
        disabled : options.disabled

    checkboxList : ->
      @_checkboxList

    val : ->
      @_checkboxList.getSelectedValue()

    setDisabled : (value) ->
      @_checkboxList.setDisabled value

  j3.DropdownListFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dropdownList = @createFormControl options,
        cls : j3.DropdownList
        id : @getControlId()
        items : options.items
        itemsDatasource : options.itemsDatasource
        fixedItemsDatasource : options.fixedItemsDatasource
        itemDataSelector : options.itemDataSelector
        fixedItemDataSelector : options.fixedItemDataSelector
        value : options.value
        placeholder : options.placeholder
        icon : options.controlIcon
        disabled : options.disabled

    dropdownList : ->
      @_dropdownList

    val : ->
      @_dropdownList.getSelectedValue()

    setDisabled : (value) ->
      @_dropdownList.setDisabled value

  j3.DropdownTreeFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dropdownTree = @createFormControl options,
        cls : j3.DropdownTree
        id : @getControlId()
        placeholder : options.placeholder
        treeOptions : options.treeOptions
        textName : options.textName
        itemsValName : options.itemsValName
        itemsTextName : options.itemsTextName
        itemsDatasource : options.itemsDatasource
        icon : options.controlIcon
        disabled : options.disabled

    dropdownTree : ->
      @_dropdownTree

    val : ->
      @_dropdownTree.getSelectedValue()

    setDisabled : (value) ->
      @_dropdownTree.setDisabled value

  j3.DateSelectorFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dateSelector = @createFormControl options,
        cls : j3.DateSelector
        id : @getControlId()
        date : options.value
        placeholder : options.placeholder
        icon : options.controlIcon
        disabled : options.disabled

    dateSelector : ->
      @_dateSelector

    val : ->
      @_dateSelector.getDate()

    setDisabled : (value) ->
      @_dateSelector.setDisabled value

  j3.DateDurationFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_beginDateSelector = @createFormControl options,
        cls : j3.DateSelector
        id : @getControlId()
        date : options.beginValue
        placeholder : options.beginPlaceholder
        name : options.beginName
        mini : yes
        icon : options.beginControlIcon
        disabled : options.disabled

      @_endDateSelector = @createFormControl options,
        cls : j3.DateSelector
        date : options.endValue
        placeholder : options.endPlaceholder
        name : options.endName
        mini : yes
        icon : options.endControlIcon
        disabled : options.disabled

    renderChildren : (sb) ->
      @_beginDateSelector.render sb
      sb.a '<span class="form-controls-connector">-</span>'
      @_endDateSelector.render sb

    setDisabled : (value) ->
      @_beginDateSelector.setDisabled value
      @_endDateSelector.setDisabled value

  j3.SwitchFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_switch = @createFormControl options,
        cls : j3.Switch
        id : @getControlId()
        checked : options.value

    switch : ->
      @_switch

    val : ->
      @_switch.getChecked()
