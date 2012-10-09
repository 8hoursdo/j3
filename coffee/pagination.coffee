do(j3) ->
  j3.Pagination = Pagination = j3.cls j3.ContainerView,
    baseCss : 'pgn'

    onInit : (options) ->
      @_pageSize = options.pageSize || 50
      @_pageNum = options.pageNum || 1
      @_entryCount = options.entryCount || 0

      @_align = options.align
      @_hidePrevNextButtons = options.hidePrevNextButtons
      @_hidePageButtons = options.hidePageButtons

    render : (sb) ->
      sb.a '<div id="' + @id + '" class="' + @getCss() + '">'
      __renderPagination.call this, sb
      sb.a '</div>'

    onCreated : ->
      j3.on @el, 'click', this, __el_click

    refresh : ->
      sb = new j3.StringBuilder
      __renderPagination.call this, sb
      @el.innerHTML = sb.toString()

    getPageNum : ->
      @_pageNum

    setPageNum : (value, noRefresh) ->
      value = value || 1
      if @_pageNum is value then return

      @_pageNum = value
      if not noRefresh then @refresh()
      @fire 'pageNumChange', this

    getPageSize : ->
      @_pageSize

    setPageSize : (value, noRefresh) ->
      @_pageSize = value || 50
      @setPageNum 1

    getEntryCount : ->
      @_entryCount

    setEntryCount : (value, noRefresh) ->
      @_entryCount = value || 0
      if not noRefresh then @refresh()

    getPageCount : ->
      if @_entryCount is 0
        return 1

      Math.floor((@_entryCount - 1) / @_pageSize) + 1

  __renderPagination = (sb) ->
    sb.a '<ul class="'
    if @_align is 'left'
      sb.a 'pull-left'
    else if @_align is 'right'
      sb.a 'pull-right'
    sb.a '">'

    pageCount = @getPageCount()
    if not @_hidePrevNextButtons
      if @_pageNum is 1
        sb.a '<li>&lt;</li>'
      else
        sb.a '<li><a href="javascript:;" data-cmd="prev">&lt;</a></li>'

    for i in [1..pageCount]
      sb.a '<li>'
      if @_pageNum is i
        sb.a i
      else
        sb.a '<a href="javascript:;" data-cmd="page" data-page="' + i + '">' + i + '</a>'
      sb.a '</li>'

    if not @_hidePrevNextButtons
      if  @_pageNum is pageCount
        sb.a '<li>&gt;</li>'
      else
        sb.a '<li><a href="javascript:;" data-cmd="next">&gt;</a></li>'

    sb.a '</ul>'

  __el_click = (evt) ->
    src = evt.src()
    cmd = j3.Dom.data src, 'cmd'
    if not cmd then return

    switch cmd
      when 'prev'
        @setPageNum @getPageNum() - 1
      when 'next'
        @setPageNum @getPageNum() + 1
      when 'page'
        @setPageNum parseInt j3.Dom.data src, 'page'
