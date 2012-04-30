do (j3) ->
  j3.FormItem = j3.cls j3.ContainerView,
    baseCss : 'form-item'

    templateBegin : j3.template '<div id="<%=id%>" class="<%=css%>"><label class="form-label" for="<%=controlId%>"><%=label%></label><div class="form-controls">'

    templateEnd : j3.template '<%if(helpText){%><span class="form-help"><%=helpText%><span><%}%></div></div>'

    onInit : (options) ->
      @_label = options.label
      @_inline = options.inline
      @_stacked = options.stacked
      @_compact = options.compact
      @_isFirst = options.isFirst
      @_helpText = options.helpText

      if not options.controlId then options.controlId = j3.View.genId()
      @_controlId = options.controlId

    getTemplateData : ->
      id : @id
      label : @_label
      css : @getCss() +
        (if @_inline then ' ' + @baseCss + '-inline' else '') +
        (if @_stacked then ' ' + @baseCss + '-stacked' else '') +
        (if @_compact then ' ' + @baseCss + '-compact' else '') +
        (if @_isFirst then ' ' + @baseCss + '-first' else '')
      controlId : @_controlId
      helpText : @_helpText


  j3.TextboxFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_textbox = new j3.Textbox
        id : options.controlId
        text : options.value
        multiline : options.multiline
        type : options.type
        placeholder : options.placeholder
        name : options.name
        datasource : options.datasource
        fill : options.controlFill
        width : options.controlWidth
        on : options.on
        parent : this

    textbox : ->
      @_textbox

    val : ->
      @_textbox.getText()

  j3.DropdownListFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dropdownList = new j3.DropdownList
        id : options.controlId
        items : options.items
        value : options.value
        placeholder : options.placeholder
        name : options.name
        datasource : options.datasource
        fill : options.controlFill
        width : options.controlWidth
        on : options.on
        parent : this

    dropdownList : ->
      @_dropdownList

    val : ->
      @_dropdownList.getSelectedValue()

  j3.DateSelectorFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_dateSelector = new j3.DateSelector
        id : options.controlId
        date : options.value
        fill : options.controlFill
        width : options.controlWidth
        placeholder : options.placeholder
        name : options.name
        datasource : options.datasource
        on : options.on
        parent : this

    dateSelector : ->
      @_dateSelector

    val : ->
      @_dateSelector.getDate()

  j3.SwitchFormItem = j3.cls j3.FormItem,
    createChildren : (options) ->
      @_switch = new j3.Switch
        id : options.controlId
        checked : options.value
        name : options.name
        datasource : options.datasource
        on : options.on
        parent : this

    switch : ->
      @_switch

    val : ->
      @_switch.checked()
