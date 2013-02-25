j3.List = j3.cls
  ctor : ->
    @_count = 0
    return
    
  firstNode : ->
    @_first

  first : ->
    @_first && @_first.value

  lastNode : ->
    @_last

  last : ->
    @_last && @_last.value

  count : ->
    @_count

  insertNode : (node, target) ->
    if node is target then return this

    if node.list
      if target
        # move to position of target
        # pick out
        if node.next
          node.next.prev = node.prev
        else
          @_last = node.prev
        if node.prev
          node.prev.next = node.next
        else
          @_first = node.next

        # put in
        node.prev = target.prev
        node.next = target
        if target.prev
          target.prev.next = node
          target.prev = node
        else
          @_first = node

      else
        # move to end
        if @_last is node then return this

        # pick out
        node.next.prev = node.prev
        if node.prev
          node.prev.next = node.next
        else
          @_first = node.next

        # put in
        node.prev = @_last
        node.next = null
        @_last.next = node
        @_last = node

      return this
 
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
    node = @findNode value
    if not node then return null
    removedValue = node.value
    @removeNode node
    removedValue

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

  findNode : (value, equals) ->
    node = @_first

    if equals
      while node
        if equals value, node.value
          return node
        node = node.next
    else if j3.isFunction value
      while node
        if value node.value
          return node
        node = node.next
    else if value && value.equals
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

  contains : (value, equals) ->
    null != @findNode value, equals

  getNodeAt : (index) ->
    if index < 0 or index > @_count
      return null

    node = @_first
    while index--
      node = node.next
    node
      
  getAt : (index) ->
    node = @getNodeAt index
    if node then node.value else null

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

  # forEach(callback)
  # forEach(context, callback)
  # forEach(context, args, callback)
  forEach : (context, args, callback) ->
    if !args && !callback
      callback = context
      context = null
      args = null
    else if !callback
      callback = args
      args = null

    node = @_first
    i = 0
    while node
      callback.call context, node.value, args, i
      node = node.next
      i++
    return

  tryUntil : (context, args, callback) ->
    if !args && !callback
      callback = context
      context = null
      args = null
    else if !callback
      callback = args
      args = null

    node = @_first
    i = 0
    while node
      if callback.call context, node.value, args, i
        return node.value
      node = node.next
      i++
    return

  doWhile : (context, args, callback) ->
    if !args && !callback
      callback = context
      context = null
      args = null
    else if !callback
      callback = args
      args = null

    node = @_first
    i = 0
    while node
      if not callback.call context, node.value, args, i
        return node.value
      node = node.next
      i++
    return

