do (j3) ->
  __subItemsDatasource_change = (sender, args) ->
    @updateData()

  __subItemModel_change = (sender, args) ->
    @updateData()

  __defaultFormToItemModelConvertor = (formModelData) ->
    formModelData

  __defaultItemToFormModelConvertor = (itemModel) ->
    itemModel.getData()

  j3.FormItemGroup = FormItemGroup = j3.cls j3.ContainerView,
    baseCss : 'form-item-group'

    onInit : (options) ->
      # individual / map / array
      @_bindingMode = options.bindingMode || 'individual'
      @_childOptionsProvider = options.childOptionsProvider
      @_formToItemModelConvertor = options.formToItemModelConvertor || __defaultFormToItemModelConvertor
      @_itemToFormModelConvertor = options.itemToFormModelConvertor || __defaultItemToFormModelConvertor

      @setDatasource options.datasource
      return

    createChildren : (options) ->
      # 数据绑定模式为数组或者字典模式时，
      # 需要创建一个数据源，将其作为子表单项的数据源进行绑定。
      if @_bindingMode is 'map'
        @_subItemsDatasource = new j3.Model
        @_subItemsDatasource.on 'change', this, __subItemsDatasource_change

      if options.itemsDatasource
        # 当设置了itemsDatasource时绑定，绑定时会调用createChildFormItem来创建子表单项。
        options.itemsDatasource.bind this, @onUpdateItems
      else
        # 否则的话，调用基类的createChildren方法来创建子表单项
        FormItemGroup.base().createChildren.call this, options

      return

    # 创建子表单项
    createChildFormItem : (item, args) ->
      childOptions = @_childOptionsProvider item
      @createChild childOptions, args

      return

    onCreateChild : (options) ->
      if @_bindingMode is 'map'
        options.datasource = @_subItemsDatasource

      if @_bindingMode is 'array'
        itemModel = new j3.Model
        itemModel.on 'change', this, __subItemModel_change
        options.datasource = itemModel

      return

    onUpdateData : ->
      # 独立模式的数据绑定由子表单项自行处理
      if @_bindingMode is 'individual'
        return

      if @_bindingMode is 'map'
        @getDatasource().set @name, @_subItemsDatasource.getData()
        return

      if @_bindingMode is 'array'
        subItemsValue = []
        j3.forEach @getChildren(), this, (child, args, index) ->
          formModelData = @_itemToFormModelConvertor child.getDatasource(), child
          subItemsValue.push formModelData
        @getDatasource().set @name, subItemsValue
        return

    onUpdateView : (datasource, eventName, args) ->
      # 独立模式的数据绑定由子表单项自行处理
      if @_bindingMode is 'individual'
        return

      subItemsValue = @getDatasource().get @name

      if @_bindingMode is 'map'
        @_subItemsDatasource.set subItemsValue || {}
        return

      if @_bindingMode is 'array'
        if not subItemsValue then subItemsValue = []
        j3.forEach @getChildren(), this, (child, args, index) ->
          itemModelData = @_formToItemModelConvertor subItemsValue[index], child
          child.getDatasource().set itemModelData || {}
        return

    onUpdateItems : (datasource, eventName, args) ->
      if @_updatingItems then return
      @_updatingItems = true

      if @el
        @getChildren().clear()
        @el.innerHTML = ''

      childArgs = {}
      lastIndex = datasource.count() - 1
      datasource.forEach this, (item, args, index) ->
        childArgs.index = index
        childArgs.first = index is 0
        childArgs.last = index is lastIndex

        childOptions = @_childOptionsProvider item, childArgs
        childOptions.parent = this
        @createChild childOptions, childArgs

      @_updatingItems = false
      return

  j3.ext FormItemGroup.prototype, j3.DataView
