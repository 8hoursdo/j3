j3.List = j3.cls
  ctor : ->
    @_count = 0
    return
    
  firstNode : ->
    @_first

  first : ->
    @_first.value

  lastNode : ->
    @_last

  last : ->
    @_last.value

  count : ->
    @_count

  insertNode : (node, target) ->
    node.list = this

    if !@_first
      # empty list
      node.prev = node.next = null
      @_first = @_last = node
    else if !target
      # insert to end
      node.next = null
      node.prev = @_last
      @_last.next = node
      @_last = node
    else
      # insert before the target
      node.next = target
      node.prev = target.prev
      target.prev = node
      if !node.prev
        # target is the first
        @_first = node
      else
        node.prev.next = node

    @_count++
    this

  insert : (value, target) ->
    @insertNode value:value, target

  removeNode : (node) ->
    if node
      if node is @_first
        @_first = node.next
      else
        node.prev.next = node.next

      if node is @_last
        @_last = node.prev
      else
        node.next.prev = node.prev

      @_count--

      # destroy
      delete node.value
      delete node.prev
      delete node.next
      delete node.list

    this

  remove : (value) ->
    @removeNode @findNode value

  clear : ->
    node = @_first
    while node
      next = node.next

      delete node.value
      delete node.prev
      delete node.next
      delete node.list

      node = next

    @_first = @_last = null
    @_count = 0

  findNode : (value) ->
    node = @_first

    if value && value.equals
      while node
        if value.equals node.value
          return node
        node = node.next
    else
      while node
        if value == node.value
          return node
        node = node.next

    null

  contains : (value) ->
    null != @findNode value

  getNodeAt : (index) ->
    if index < 0 or index > @_count
      return null

    node = @_first
    while index--
      node = node.next
    node
      
  getAt : (index) ->
    node = @getNodeAt index
    node.value if node

  toString : ->
    sb = new j3.StringBuilder
    @toJson sb
    sb.toString()

  toJson : (sb) ->
    sb.append '['

    node = @_first
    if node
      j3.toJson node.value, sb
      node = node.next
      while node
        sb.append ','
        j3.toJson node.value, sb
        node = node.next

    sb.append ']'
    return

  forEach : (callback, context, arg) ->
    node = @_first
    while node
      callback.call context, node.value, arg
      node = node.next
    return

  tryUntil : (callback, context, arg) ->
    node = @_first
    while node
      if callback.call context, node.value, arg
        return node.value
      node = node.next
    return

  doWhile : (callback, context, arg) ->
    node = @_first
    while node
      if not callback.call context, node.value, arg
        return node.value
      node = node.next
    return

