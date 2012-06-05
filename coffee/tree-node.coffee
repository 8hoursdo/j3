do (j3) ->
  __renderIndents = (buffer) ->
    if @_level
      for i in [0...@_level-1]
        buffer.append '<div class="tree-node-indent"></div>'

  __refreshNode = ->
    el = @_elNodeBody
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
      @_childrenLoaded = !!options.childrenLoaded

      @_checkable = @parent.getCheckable()
      if options.hasOwnProperty 'checkable'
        @_checkable = !!options.checkable

      @_unselectable = !!options.unselectable

      @_expandOnClick = options.expandOnClick

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

        tree.beforeExpandNode && tree.beforeExpandNode args
        if args.stop then return

        tree.fire 'beforeExpandNode', tree, args
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

    remove : ->
      # We can't remove top node
      if @parent is @_tree then return

      @parent.removeNode this

    __doRemove : ->
      j3.Dom.remove @el

    removeNode : (node) ->
      if not node then return

      # If the node to be removed is active node, we should set a new active node later
      if node.getActive()
        activeNode = node.getNext()
        if not activeNode then activeNode = node.getPrevious()
        if not activeNode then activeNode = node.parent

      node.__doRemove()
      @children.remove node

      if activeNode
        @_tree._activeNode = null
        @_tree.setActiveNode activeNode

    clearChildren : ->
      if not @children then return

      activeNode = @_tree.getActiveNode()
      while activeNode and activeNode isnt @_tree and activeNode isnt @
        activeNode = activeNode.parent

      if activeNode is @
        @setActive()

      @children.clear()
      @elBody.innerHTML = ''

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

