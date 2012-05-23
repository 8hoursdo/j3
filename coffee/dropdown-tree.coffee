do (j3) ->
  __tree_activeNodeChange = (sender, args) ->
    @setSelectedItem if args.node then args.node.getData() else null
    @close()

  __tree_expand = (sender, args) ->
    @resizeDropdownBox()

  j3.DropdownTree = j3.cls j3.Dropdown,
    onInit : (options) ->
      j3.DropdownTree.base().onInit.apply this, arguments

      @_treeOptions = options.treeOptions || {}
      @_textName = options.textName || @name
      @_itemValueName = options.itemValueName || @name
      @_itemTextName = options.itemTextName || @_textName

    onCreateDropdownBox : (elBox) ->
      treeCls = @_treeOptions.cls || j3.Tree
      @_treeOptions.parent = this
      @_treeOptions.ctnr = elBox
      @_tree = new treeCls @_treeOptions

      @_tree.on 'activeNodeChange', this, __tree_activeNodeChange
      @_tree.on 'nodeExpand', this, __tree_expand

    onCreated : (options) ->
      j3.DropdownTree.base().onCreated.call this

      @_selectedValue = options.selectedValue
      @setDatasource options.datasource

    getTree : ->
      @_tree

    getSelectedItem : ->
      @_selectedItem

    setSelectedItem : (value) ->
      @_selectedItem = value

      @_selectedValue = value[@_itemValueName]
      @setLabel value[@_itemTextName]

      @updateData()

    getSelectedValue : ->
      @_selectedValue

    setSelectedValue : (value) ->
      if @_selectedValue is value then return

      @_selectedValue = value
      @fire 'change', this, value : @_selectedValue

    onUpdateView : (datasource, eventName, args) ->

    onUpdateData : ->
      @getDatasource().set @name, @_selectedValue

  j3.ext j3.DropdownTree.prototype, j3.DataView
