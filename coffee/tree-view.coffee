do (j3) ->
  __hEl_Click = (evt) ->
    el = evt.src()

    while el and el isnt @el
      if el.className is 'tree-node-expander'
        treeNode = el.parentNode.parentNode._j3TreeNode
        if treeNode
          treeNode.setExpanded !treeNode.getExpanded()
        return

      if el.className is 'tree-node'
        treeNode = el._j3TreeNode
        if treeNode
          @setActiveNode treeNode
        return
      el = el.parentNode

  j3.TreeView = j3.cls j3.View,
    baseCss : 'tree-view'

    onInit : (options) ->
      @_showTopNode = options.showTopNode
      @_checkable = !!options.checkable

    createChildren : (options) ->
      nodeOptions = options.topNode || {}
      nodeOptions.parent = this
      @_topNode = new j3.TreeNode nodeOptions

    onRender : (buffer, data) ->
      buffer.append '<div id="' + data.id + '" class="' + data.css + '">'

      @_topNode.render buffer

      buffer.append '</div>'
      return

    onCreated : ->
      j3.on @el, 'click', this, __hEl_Click

    getTopNode : ->
      @_topNode

    getLevel : ->
      -1

    getTree : ->
      this

    getCheckable : ->
      @_checkable

    getActiveNode : ->
      @_activeNode

    setActiveNode : (node) ->
      if @_activeNode is node then return

      old = @_activeNode
      if @_activeNode then @_activeNode.__doSetActive false

      @_activeNode = node
      if @_activeNode then @_activeNode.__doSetActive true

      @fire 'activeNodeChange', this, old : old, node : @_activeNode

    removeNode : (node) ->
      node.remove()
      
