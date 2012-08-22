do (j3) ->
  __renderIndents = (buffer) ->
    if @_level
      for i in [0...@_level-1]
        buffer.append '<div class="tree-node-indent"></div>'

  __refreshNode = ->
    el = @_elNodeBody

    if not el then return

    Dom = j3.Dom
    if @_childrenLoaded and (not @children or not @children.count())
      @collapse()
      Dom.addCls el, 'tree-node-leaf'
    else
      Dom.removeCls el, 'tree-node-leaf'
      if @_expanded
        Dom.addCls el, 'tree-node-expanded'
      else
        Dom.removeCls el, 'tree-node-expanded'

  __uncheckChildNodesToBeRemoved = (node, includeSelf, uncheckedNodes) ->
    if not uncheckedNodes then uncheckedNodes = []
    if includeSelf and node.getChecked()
      uncheckedNodes.push node
      node._tree._checkedNodes.remove node

    if not @children then return
    @children.forEach (node) ->
      __uncheckChildNodesToBeRemoved node, true, uncheckedNodes

    uncheckedNodes

  j3.TreeNode = j3.cls j3.ContainerView,
    baseCss : 'tree-node'

    onInit : (options) ->
      @_level = @parent.getLevel() + 1
      @_tree = @parent.getTree()

      @_data = options.data
      if options.text
        @_text = options.text
      else if @_data
        @_text = @_data[@_tree._dataTextName]
        
      @_icon = options.icon
      @_expanded = !!options.expanded
      @_childrenLoaded = !!options.childrenLoaded || options.children

      @_checkable = @parent.getCheckable()
      if options.hasOwnProperty 'checkable'
        @_checkable = !!options.checkable
      @_checked = !!options.checked

      @_unselectable = !!options.unselectable

      @_expandOnClick = options.expandOnClick

      if j3.isUndefined options.checkOnClick
        @_checkOnClick = @_tree._checkOnClick
      else
        @_checkOnClick = options.checkOnClick

      @_itemDataSelector = j3.compileSelector(options.itemDataSelector || @_tree._itemDataSelector || 'id')

      @_itemDataEquals = j3.compileEquals(options.itemDataEquals || @_tree._itemDataEquals || ['id'])

    onCreateChild : (options) ->
      options.cls = options.cls || j3.TreeNode
      options.parent = this

    renderBegin : (buffer, data) ->
      buffer.append '<div id="' + data.id + '" class="' + data.css + '">'
      buffer.append '<div class="tree-node-body'
      if @_level is 0
        buffer.append ' tree-node-top'

      if @_childrenLoaded and (not @children or not @children.count())
        buffer.append ' tree-node-leaf'
      else if @_expanded
        buffer.append ' tree-node-expanded'

      if @_checked
        buffer.append ' tree-node-checked'
      buffer.append '">'

      buffer.append '<div class="tree-node-indents">'
      __renderIndents.call this, buffer
      buffer.append '</div>'

      if @_level
        buffer.append '<div class="tree-node-expander"></div>'

      buffer.append '<div class="tree-node-content">'

      @renderNodeContent buffer

      buffer.append '</div>'
      
      buffer.append '</div>'
      buffer.append '<div class="tree-node-children'
      if !@_expanded
        buffer.append ' hide'
      buffer.append '">'

    renderEnd : (buffer) ->
      buffer.append '</div></div>'

    renderNodeContent : (buffer) ->
      if @_checkable
        buffer.append '<a class="tree-node-chk" javascript:;><i></i></a>'

      if @_icon
        buffer.append '<i class="tree-node-icon ' + @_icon + '"></i>'

      buffer.append '<span id="' + @id + '-label" class="tree-node-label">'
      buffer.append j3.htmlEncode @_text
      buffer.append '</span>'

    onCreated : (options) ->
      @_elNodeBody = j3.Dom.firstChild @el
      @_elIndent = j3.Dom.firstChild @_elNodeBody
      @elBody = j3.Dom.lastChild @el
      @_elLabel = j3.$ @id + '-label'

      @el._j3TreeNode = this

    onLoad : ->
      if @parent and @parent isnt @_tree then __refreshNode.apply @parent

    getLevel : ->
      @_level

    setLevel : (value) ->
      if @_level is value then return

      @_level = value

      buffer = new j3.StringBuilder
      __renderIndents.call this, buffer
      @_elIndent.innerHTML = buffer.toString()

      if not @children then return

      node = @children.firstNode()
      while node
        node.value.setLevel @_level + 1
        node = node.next

    getTree : ->
      @_tree

    getCheckable : ->
      @_checkable

    getChecked : ->
      @_checked

    setChecked : (value, recursive) ->
      value = !!value
      if @_checked is value then return

      @_checked = value
      j3.Dom.toggleCls @_elNodeBody, 'tree-node-checked'

      tree = @_tree
      args = node : this, checked : value

      @fire 'check', this, args
      tree.notifyNodeCheck this, value

      if recursive and @children
        @children.forEach (child) ->
          child.setChecked value, true

    getUnselectable : ->
      @_unselectable

    setUnselectable : (value) ->
      @_unselectable = value

    getExpanded : ->
      @_expanded

    setExpanded : (value) ->
      value = !!value
      if value is @_expanded then return

      tree = @_tree

      args = node : this
      if value
        @beforeExpand && @beforeExpand args
        if args.stop then return

        @fire 'beforeExpand', this, args
        if args.stop then return

        tree.beforeNodeExpand && tree.beforeNodeExpand args
        if args.stop then return

        tree.fire 'beforeNodeExpand', tree, args
        if args.stop then return

      j3.Dom.toggleCls @_elNodeBody, 'tree-node-expanded'
      j3.Dom.toggleCls @elBody, 'hide'

      @_expanded = value

      if value
        @fire 'expand', this

        tree.onNodeExpand && tree.onNodeExpand args

        tree.fire 'nodeExpand', tree, args

    expand : (recursive) ->
      @setExpanded true

      if recursive and @children
        @children.forEach (child) ->
          child.expand true

    collapse : (recursive) ->
      @setExpanded false

      if recursive and @children
        @children.forEach (child) ->
          child.collapse true

    click : ->
      if @_expandOnClick
        @expand()

      if @_checkOnClick and @_checkable
        @setChecked not @getChecked()

    getActive : ->
      @_tree.getActiveNode() is this

    setActive : ->
      @_tree.setActiveNode this

    __doSetActive : (value) ->
      if value
        j3.Dom.addCls @_elNodeBody, 'tree-node-active'
      else
        j3.Dom.removeCls @_elNodeBody, 'tree-node-active'
      return

    __doSetHover : (value) ->
      if value
        j3.Dom.addCls @_elNodeBody, 'tree-node-hover'
      else
        j3.Dom.removeCls @_elNodeBody, 'tree-node-hover'

    insert : (child) ->
      if child.parent is this then return

      child.parent.children.remove child

      if not @_childrenLoaded
        @expand()
        return

      child.parent = this
      @getChildren().insert child
      @elBody.appendChild child.el
      child.setLevel @_level + 1

    remove : (silent) ->
      tree = @_tree
      parentNode = @parent
      # We can't remove top node
      if parentNode is tree then return

      # If the node to be removed is active node, we should set a new active node later
      if @getActive()
        activeNode = @getNext()
        if not activeNode then activeNode = @getPrevious()
        if not activeNode then activeNode = parentNode

      # Remove from checked node list of tree if nodes to be removed is checked.
      uncheckedNodes = __uncheckChildNodesToBeRemoved this, true

      j3.Dom.remove @el
      parentNode.children.remove this

      if activeNode
        tree._activeNode = null
        tree.setActiveNode activeNode

      __refreshNode.call parentNode

      if uncheckedNodes and uncheckedNodes.length and not silent
        tree.fire 'checkedNodesChange', tree, uncheckedNodes : uncheckedNodes

    clearChildren : (silent) ->
      if not @children then return

      activeNode = @_tree.getActiveNode()
      while activeNode and activeNode isnt @_tree and activeNode isnt this
        activeNode = activeNode.parent

      if activeNode is this
        @setActive()

      uncheckedNodes = __uncheckChildNodesToBeRemoved this, false

      @children.clear()
      @elBody.innerHTML = ''

      __refreshNode.call this

      if uncheckedNodes and uncheckedNodes.length and not silent
        tree.fire 'checkedNodesChange', tree, uncheckedNodes : uncheckedNodes

    getText : ->
      @_text

    setText : (value) ->
      @_text = value
      @_elLabel.innerHTML = j3.htmlEncode @_text

    getData : ->
      @_data

    setData : (value) ->
      @_data = value

      if @_data
        dataTextName = @_tree._dataTextName
        if dataTextName
          @setText @_data[dataTextName]

    getItemData : ->
      @_itemDataSelector @_data

    getNodeByDataId : (id) ->
      if @_data && @_data[@_tree._dataIdName] is id
        return this

      if not @children then return null

      node = @children.firstNode()
      while node
        treeNode = node.value.getNodeByDataId id
        if treeNode then return treeNode
        node = node.next

      return null

    getChildrenLoaded : ->
      @_childrenLoaded

    setChildrenLoaded : (value) ->
      @_childrenLoaded = value

    getNext : ->
      el = j3.Dom.next @el
      el && el._j3TreeNode

    getPrevious : ->
      el = j3.Dom.previous @el
      el && el._j3TreeNode

