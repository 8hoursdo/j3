do (j3) ->

  j3.TreeNode = j3.cls j3.ContainerView,
    baseCss : 'tree-node'

    onInit : (options) ->
      @_text = options.text
      @_data = options.data
      @_icon = options.icon
      @_expanded = !!options.expanded
      @_childrenLoaded = !!options.childrenLoaded

      @_checkable = @parent.getCheckable()
      if options.hasOwnProperty 'checkable'
        @_checkable = !!options.checkable

      @_level = @parent.getLevel() + 1
      @_tree = @parent.getTree()

    onCreateChild : (options) ->
      options.cls = options.cls || j3.TreeNode
      options.parent = this

    renderBegin : (buffer, data) ->
      buffer.append '<div id="' + data.id + '" class="' + data.css + '">'
      buffer.append '<div class="tree-node-body'
      if @getLevel() is 0
        buffer.append ' tree-node-top'
      if @_expanded
        buffer.append ' tree-node-expanded'
      buffer.append '">'

      buffer.append '<div class="tree-node-idents">'
      for i in [0...@_level]
        buffer.append '<div class="tree-node-ident"></div>'
      buffer.append '</div>'

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
      @elBody = j3.Dom.lastChild @el
      @_elLabel = j3.$ @id + '-label'

      @el._j3TreeNode = this

    getCheckable : ->
      @_checkable

    getLevel : ->
      @_level

    getTree : ->
      @_tree

    getExpanded : ->
      @_expanded

    setExpanded : (value) ->
      value = !!value
      if value is @_expanded then return

      tree = @_tree

      args = node : this
      if value
        @fire 'beforeExpand', this

        tree.beforeExpandNode? args
        tree.fire 'beforeExpandNode', tree, args

        if args.stop then return

      j3.Dom.toggleCls @_elNodeBody, 'tree-node-expanded'
      j3.Dom.toggleCls @elBody, 'hide'

      @_expanded = value

      if value
        @fire 'expand', this
        tree.onNodeExpanded? args
        tree.fire 'expandNode', tree, args

    getActive : ->
      @_tree.getActiveNode() is this

    setActive : ->
      @_tree.setActiveNode this

    __doSetActive : (value) ->
      if value
        j3.Dom.toggleCls @_elNodeBody, 'tree-node-active'
      else
        j3.Dom.removeCls @_elNodeBody, 'tree-node-active'
      return

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
        activeNode = currentActiveNode.parent

      if activeNode is @
        @setActive()

      @children.clear()
      @_elNodeBody.innerHTML = ''

    getText : ->
      @_text

    setText : (value) ->
      @_text = value
      @_elLabel.innerHTML = j3.htmlEncode @_text

    getData : ->
      @_data

    setData : (value) ->
      @_data = value

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

