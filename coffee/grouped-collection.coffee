do (j3) ->
  __insertModelToGroup = (model, group) ->
    model.group = group

    items = group.items
    if not items then group.items = items = new j3.List
    items.insert model

  __removeModelFromGroup = (model) ->
    group = model.group
    if not group then return

    model.group = null

    items = group.items
    if items then items.remove model

  __getFirstNodeGreatThan = (list, value, comparer) ->
    node = list.firstNode()
    while node
      if node.value isnt value and 0 < comparer node.value._data, value._data
        return node
      node = node.next
    null

  j3.GroupedCollection = GroupedCollection = j3.cls
    ctor : (options) ->
      options ?= {}

      if options.id
        @id = options.id
        _collections[@id] = this

      @_idName = options.idName || 'id'
      @_idxId = {}
      @_model = options.model || j3.Model
      @_models = new j3.List

      @_groupIdName = options.groupIdName || 'id'
      @_groupMap = {}
      @_groupModel = options.groupModel || j3.Model
      @_groupList = new j3.List
      if options.groupBy
        @_groupBy = j3.compileGroupBy options.groupBy
      if options.groupSortBy
        @_groupSortBy = j3.compileSortBy options.groupSortBy

      options.on && @on options.on
      return

    getModel : ->
      @_model

    getData : (name) ->
      if not @_data then return null
      @_data[name]

    setData : (name, value) ->
      if not @_data then @_data = {}
      @_data[name] = value

    insertGroup : (data, options) ->
      options ?= {}

      group = new @_groupModel data
      group.notifyChangeName = 'groupDataChange'
      group.collection = this

      id = group.get @_groupIdName
      if id then @_groupMap[id] = group

      if @_groupSortBy
        groupNodeToInsert = __getFirstNodeGreatThan @_groupList, group, @_groupSortBy
      @_groupList.insert group, groupNodeToInsert

      if not options.silent
        @updateViews 'groupAdd', group : group

    removeGroup : (group, options) ->
      if not group then return

      options ?= {}
      node = @_groupList.findNode group
      if @_activeGroup is group
        newActiveGroup = node.next && node.next.value
        if not newActiveGroup then newActiveGroup = node.prev && node.prev.value

      @_groupList.removeNode node
      delete @_groupMap[group.get @_groupIdName]

      if not options.silent
        @updateViews 'groupRemove', group : group

      if newActiveGroup
        @setActiveGroup newActiveGroup, options

    removeGroupById : (id, options) ->
      group = @getGroupById id
      if group then @removeGroup group, options

    removeActiveGroup : (options) ->
      if @_activeGroup then @removeGroup @_activeGroup, options
    
    insert : (data, options) ->
      options ?= {}

      if data instanceof @_model
        model = data
      else
        model = new @_model data

      id = model.get @_idName
      if id
        @_idxId[id] = model

      if options.group
        __insertModelToGroup model, options.group
      else
        # decide which group to insert
        groupId = @_groupBy model
        group = @getGroupById groupId
        if not group then return
        __insertModelToGroup model, group

      model.collection = this
      @_models.insert model

      if not options.silent
        @updateViews 'add', model : model

    remove : (model, options) ->
      if not model then return

      options ?= {}

      node = @_models.findNode model
      if @_activeModel is model
        newActiveModel = node.next && node.next.value
        if not newActiveModel then newActiveModel = node.prev && node.prev.value

      __removeModelFromGroup model

      delete @_idxId[model.get @_idName]
      @_models.removeNode node

      if not options.silent
        @updateViews 'remove', model : model
      if newActiveModel
        @setActive newActiveModel, options

    removeById : (id, options) ->
      model = @getById id
      if model then @remove model, options

    removeActive : (options) ->
      if @_activeModel then @remove @_activeModel, options

    clear : (options) ->
      options ?= {}

      @_idxId = {}
      @_models.clear()

      @forEachGroup (group) ->
        group.items && group.items.clear()

      if not options.silent
        @updateViews 'refresh'
        @fire 'refresh', this

    clearGroup : (options) ->
      options ?= {}

      @_idxId = {}
      @_models.clear()

      @_groupMap = {}
      @_groupList.clear()

      if not options.silent
        @updateViews 'refresh'
        @fire 'refresh', this

    loadGroupData : (groupDataList, options) ->
      options ?= {}

      silent = options.silent
      options.silent = true

      @clearGroup options
      for groupData in groupDataList
        @insertGroup groupData, options

      if not j3.isUndefined options.activeIndex
        @setActiveGroup @_groupList.getAt options.activeIndex

      if not silent
        @updateViews 'refresh'
        @fire 'refresh', this

    loadData : (dataList, options) ->
      options = options || {}

      silent = options.silent
      options.silent = true
      @clear options
      for data in dataList
        @insert data, options

      if not j3.isUndefined options.activeIndex
        @setActive @_models.getAt options.activeIndex

      if not silent
        @updateViews 'refresh'
        @fire 'refresh', this

    getActiveGroup : ->
      @_activeGroup

    setActiveGroup : (group, options) ->
      if @_activeGroup is group then return

      options = options || {}

      old = @_activeGroup
      @_activeGroup = group

      if not options.silent
        args = old : old, group : group
        @updateViews 'activeGroup', args
        @fire 'activeGroupChange', this, args

    setActiveGroupByIndex : (index, options) ->
      if index >= @_groupList.count() or index < 0
        index = -1

      @setActiveGroup @getGroupAt(index), options

    getGroupById : (id) ->
      if not id then return null

      @_groupMap[id]

    getGroupAt : (index) ->
      @_groupList.getAt index

    groupCount : ->
      @_groupList.count()

    getActive : ->
      @_activeModel

    setActive : (model, options) ->
      if @_activeModel is model then return

      options = options || {}

      old = @_activeModel
      @_activeModel = model

      if not options.silent
        args = old : old, model : model
        @updateViews 'active', args
        @fire 'activeModelChange', this, args

    setActiveByIndex : (index, options) ->
      if index >= @count() or index < 0
        index = -1

      @setActive @getAt(index), options

    notifyModelChange : (changeName, args) ->
      if changeName is 'groupDataChange'
        if @_groupSortBy
          group = args.model
          if group
            targetNode = __getFirstNodeGreatThan @_groupList, group, @_groupSortBy
            groupNode = @_groupList.findNode group
            @_groupList.insertNode groupNode, targetNode

      @updateViews changeName, args
      @fire changeName, this, args

    getById : (id, callback) ->
      if not id then return null

      @_idxId[id]

    getAt : (index) ->
      @_models.getAt index

    count : ->
      @_models.count()

    forEach : (context, args, callback) ->
      @_models.forEach context, args, callback

    tryUntil : (context, args, callback) ->
      @_models.tryUntil context, args, callback

    doWhile : (context, args, callback) ->
      @_models.doWhile context, args, callback

    forEachGroup : (context, args, callback) ->
      @_groupList.forEach context, args, callback

    tryUntilGroup : (context, args, callback) ->
      @_groupList.tryUntil context, args, callback

    doWhileGroup : (context, args, callback) ->
      @_groupList.doWhile context, args, callback

  j3.ext GroupedCollection.prototype, j3.Datasource, j3.EventManager
