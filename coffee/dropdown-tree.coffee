do (j3) ->
  __tree_nodeClick = (sender, args) ->
    node = args.node
    if node.getUnselectable() then return

    @setSelectedItem if node then node.getData() else null
    @close()

  __tree_nodeExpand = (sender, args) ->
    @resizeDropdownBox()

  __getItemByValue = (value, callback) ->
    if not value then return callback null

    datasource = @getItemsDatasource()
    if not datasource then return

    datasource.getById value, callback

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

    getSelectedItem : ->
      @_selectedItem

    setSelectedItem : (value) ->
      @_selectedItem = value

      selectedValue = value[@_itemsValName]
      if @_selectedValue is selectedValue then return
      @_selectedValue = selectedValue

      @setSelectedText value[@_itemsTextName] || @_selectedValue || ''

      @updateData()
      @fire 'change', this, value : selectedValue

    getSelectedText : ->
      @_selectedText

    setSelectedText : (value) ->
      @_selectedText = value
      @setLabel @_selectedText

    getSelectedValue : ->
      @_selectedValue

    setSelectedValue : (value) ->
      if @_selectedValue is value then return

      __getItemByValue.call this, value, (item) =>
        if item
          @_selectedValue = value
          @setSelectedText j3.getVal(item, @_itemsTextName)
        else
          @_selectedValue = null
          @setSelectedText ''

        @fire 'change', this, value : @_selectedValue

    onUpdateView : (datasource, eventName, args) ->
      value = datasource.get @name

      @setSelectedValue value

    onUpdateData : ->
      datasource = @getDatasource()
      data = {}
      data[@name] = @_selectedValue
      if @_textName
        data[@_textName] = @_selectedText

      datasource.set data, append : true

    onUpdateViewItems : (datasource, eventName, args) ->

  j3.ext j3.DropdownTree.prototype, j3.DataView, j3.DataItemsView
