do (j3) ->
  j3.CheckboxList = j3.cls j3.ContainerView,
    baseCss : 'chk-list'

    onInit : (options) ->
      # 指示是否一行内显示多个checkbox
      @_itemInline = !!options.itemInline
      # 设置在inline模式下，每个checkbox的宽度
      # 如果不设置，以紧凑模式排列
      @_itemWidth = options.itemWidth

      @_items = options.items
      @_itemsDatasource = options.itemsDatasource

      # array / bit
      @_bindingMode = options.bindingMode || 'array'

      @setSelectedValue options.selectedValue
      @setDatasource options.datasource

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_itemInline then ' ' + @baseCss + '-inline' else '')
      text : @_text

    createChildren : (options) ->
      items = @_items || @_itemsDatasource
      if not items then return

      bindingMode = @_bindingMode
      selectedValue = @_selectedValue
      j3.forEach items, this, (item) ->
        value = j3.getVal item, 'value'
        itemOptions =
          parent : this
          text : j3.getVal item, 'text'
          value : value
          inline : @_itemInline
          checked : __shouldChecked selectedValue, value, bindingMode
          on :
            change : c : this, h : __chk_change

        if @_itemInline && @_itemWidth
          itemOptions.width = @_itemWidth

        new j3.Checkbox itemOptions

    onUpdateData : ->
      datasource = @getDatasource()
      datasource.set @name, j3.clone @_selectedValue

    onUpdateView : (datasource, eventName, args) ->
      @setSelectedValue datasource.get @name

      if not @el then return

      @_updatingSubComponent = yes
      bindingMode = @_bindingMode
      j3.forEach @children, this, (chk) ->
        chk.setChecked __shouldChecked @_selectedValue, chk.getValue(), bindingMode
      @_updatingSubComponent = no

    getSelectedValue : ->
      @_selectedValue

    setSelectedValue : (value) ->
      if value
        @_selectedValue = j3.clone value
      else
        if @_bindingMode is 'array'
          @_selectedValue = []
        else
          @_selectedValue = 0

  j3.ext j3.CheckboxList.prototype, j3.DataView

  __shouldChecked = (selectedValue, value, bindingMode) ->
    if bindingMode is 'bit'
      !! (selectedValue & value)
    else if bindingMode is 'array'
      -1 isnt j3.indexOf(selectedValue, value)

  __chk_change = (sender, args) ->
    if @_updatingSubComponent then return

    bindingMode = @_bindingMode
    value = sender.getValue()

    if bindingMode is 'bit'
      if sender.getChecked()
        @_selectedValue |= value
      else
        @_selectedValue &= ~value

    else if bindingMode is 'array'
      if sender.getChecked()
        @_selectedValue.push value
      else
        indexOfValue = j3.indexOf @_selectedValue, value
        if indexOfValue isnt -1
          @_selectedValue.splice indexOfValue, 1

    @updateData()
