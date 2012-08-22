do (j3) ->
  __hEl_click = (evt) ->
    el = evt.src()

    while el and el isnt @el
      if el.className is 'tree-node-expander'
        treeNode = el.parentNode.parentNode._j3TreeNode
        if treeNode
          treeNode.setExpanded !treeNode.getExpanded()
        return

      if el.className is 'tree-node-chk'
        treeNode = el.parentNode.parentNode.parentNode._j3TreeNode
        if treeNode
          treeNode.setChecked !treeNode.getChecked()
        return

      if el.className is 'tree-node'
        node = el._j3TreeNode
        if node
          if not node.getUnselectable()
            @setActiveNode node

          node.click()
          @fire 'nodeClick', this, node : node
        return
      el = el.parentNode

  __hEl_mousemove = (evt) ->
    el = evt.src()

    while el and el isnt @el
      if el.className is 'tree-node'
        node = el._j3TreeNode
        if node
          @setHoverNode node
        return
      el = el.parentNode

  __hEl_mouseout = (evt) ->
    @setHoverNode null

  j3.TreeView = j3.cls j3.View,
    baseCss : 'tree-view'

    onInit : (options) ->
      @_checkable = !!options.checkable
      @_dataIdName = options.dataIdName || 'id'
      @_dataTextName = options.dataTextName || 'name'
      @_topNodeHidden = !!options.topNodeHidden

      if j3.isUndefined options.checkOnClick
        @_checkOnClick = true
      else
        @_checkOnClick = !!options.checkOnClick

      @_itemDataSelector = j3.compileSelector(options.itemDataSelector || 'id')

      @_itemDataEquals = j3.compileEquals(options.itemDataEquals || ['id'])

    createChildren : (options) ->
      nodeOptions = options.topNode || {}
      nodeOptions.parent = this
      nodeOptions.expanded = true
      @_topNode = new j3.TreeNode nodeOptions

    onRender : (buffer, data) ->
      buffer.append '<div id="' + data.id + '" class="' + data.css
      if @_topNodeHidden
        buffer.append ' tree-view-hide-top-node'
      buffer.append '">'

      @_topNode.render buffer

      buffer.append '</div>'
      return

    onCreated : ->
      j3.on @el, 'click', this, __hEl_click
      j3.on @el, 'mousemove', this, __hEl_mousemove
      j3.on @el, 'mouseout', this, __hEl_mouseout

    getLevel : ->
      -1

    getTree : ->
      this

    getCheckable : ->
      @_checkable

    getTopNode : ->
      @_topNode

    getNodeByDataId : (id) ->
      @getTopNode().getNodeByDataId id

    getActiveNode : ->
      @_activeNode

    setActiveNode : (node) ->
      if @_topNodeHidden and node is @getTopNode()
        node = null

      if node && node.getUnselectable()
        node = null

      if @_activeNode is node then return

      old = @_activeNode
      if @_activeNode then @_activeNode.__doSetActive false

      @_activeNode = node
      if @_activeNode then @_activeNode.__doSetActive true

      @fire 'activeNodeChange', this, old : old, node : @_activeNode

    getHoverNode : ->
      @_hoverNode

    setHoverNode : (node) ->
      if @_topNodeHidden and node is @getTopNode()
        node = null

      if node && node.getUnselectable()
        node = null

      if @_hoverNode is node then return

      old = @_hoverNode
      if @_hoverNode then @_hoverNode.__doSetHover false

      @_hoverNode = node
      if @_hoverNode then @_hoverNode.__doSetHover true

      @fire 'hoverNodeChange', this, old : old, node : @_hoverNode

    removeNode : (node) ->
      node.remove()

    notifyNodeCheck : (node, checked, silent) ->
      if not @_checkedNodes then @_checkedNodes = new j3.List

      args = {}
      if checked
        @_checkedNodes.insert node
        args.checkedNodes = [node]
      else
        @_checkedNodes.remove node
        args.uncheckedNodes = [node]

      if not silent
        @fire 'checkedNodesChange', this, args

    getCheckedNodes : ->
      @_checkedNodes

    getSelectedItems : ->
      selectedItems = []
      if not @_checkedNodes then return selectedItems

      @_checkedNodes.forEach (node) ->
        selectedItems.push node.getItemData()

      
