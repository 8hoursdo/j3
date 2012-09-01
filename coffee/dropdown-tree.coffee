do (j3) ->
  __tree_nodeClick = (sender, args) ->
    node = args.node
    if node.getUnselectable() then return

    @close()
    
    selectedItem = null
    if node
      nodeData = node.getData()
      selectedItem =
        text : j3.getVal nodeData, @_itemsTextName
        value : j3.getVal nodeData, @_itemsValName
    __setSelectedItemInternal.call this, selectedItem

  __tree_nodeExpand = (sender, args) ->
    @resizeDropdownBox()

  __getDataItemByValue = (value, callback) ->
    if not value then return callback null

    datasource = @getItemsDatasource()
    if not datasource then return

    datasource.getById value, callback

  __setSelectedItemInternal = (selectedItem) ->
    selectedValue = (selectedItem && selectedItem.value) || null

    if @_selectedValue is selectedValue then return
    @_selectedValue = selectedValue

    @updateData()

    @doSetSelectedItems selectedItem

    @fire 'change', this, value : selectedValue

  j3.DropdownTree = j3.cls j3.Dropdown,
    onInit : (options) ->
      j3.DropdownTree.base().onInit.apply this, arguments

      @_treeOptions = options.treeOptions || {}
      @_textName = options.textName
      @_itemsValName = options.itemsValName || @name
      @_itemsTextName = options.itemsTextName || @_itemsValName

    onCreateDropdownBox : (elBox) ->
      treeCls = @_treeOptions.cls || j3.Tree
      @_treeOptions.parent = this
      @_treeOptions.ctnr = elBox
      @_tree = new treeCls @_treeOptions

      @_tree.on 'nodeClick', this, __tree_nodeClick
      @_tree.on 'nodeExpand', this, __tree_nodeExpand

      @fire 'treeLoad', this, tree : @_tree

    onCreated : (options) ->
      j3.DropdownTree.base().onCreated.call this

      @_selectedValue = options.selectedValue
      @setDatasource options.datasource

      @setItemsDatasource options.itemsDatasource

    onDropdown : ->
      topNode = @_tree.getTopNode()
      topNode.expand()
      @_tree.setActiveNode null

    getTree : ->
      @_tree

    getSelectedValue : ->
      @_selectedValue

    setSelectedValue : (value) ->
      if @_selectedValue is value then return

      __getDataItemByValue.call this, value, (dataItem) =>
        if dataItem
          selectedItem =
            text : j3.getVal dataItem, @_itemsTextName
            value : j3.getVal dataItem, @_itemsValName
        __setSelectedItemInternal.call this, selectedItem

    onUpdateView : (datasource, eventName, args) ->
      if args and args.changedData and not args.changedData.hasOwnProperty @name then return
      @setSelectedValue datasource.get @name

    onUpdateData : ->
      datasource = @getDatasource()
      data = {}
      data[@name] = @_selectedValue
      if @_textName
        data[@_textName] = @_selectedText

      datasource.set data, append : true

    onUpdateViewItems : (datasource, eventName, args) ->

  j3.ext j3.DropdownTree.prototype, j3.DataView, j3.DataItemsView
