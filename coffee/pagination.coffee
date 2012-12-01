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

      # 指示是否在只有一页时自动隐藏分页条
      @_autoHide = options.autoHide

    render : (sb) ->
      sb.a '<div id="' + @id + '" class="' + @getCss() + '"'

      if @_autoHide
        pageCount = @getPageCount()
        if pageCount is 1
          sb.a ' style="display:none"'

      sb.a '>'
      __renderPagination.call this, sb
      sb.a '</div>'

    onCreated : ->
      j3.on @el, 'click', this, __el_click

    refresh : ->
      sb = new j3.StringBuilder
      __renderPagination.call this, sb
      @el.innerHTML = sb.toString()

      if @_autoHide
        pageCount = @getPageCount()
        if pageCount is 1
          this.hide()
        else
          this.show()

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
    pageCount = @getPageCount()

    if not @_hidePrevNextButtons
      if @_pageNum isnt 1
        sb.a '<a class="pgn-prev" href="javascript:;" data-cmd="prev">&lt;</a>'

      if @_pageNum isnt pageCount
        sb.a '<a class="pgn-next" href="javascript:;" data-cmd="next">&gt;</a>'

    sb.a '<ul class="'
    if @_align is 'left'
      sb.a 'pull-left'
    else if @_align is 'right'
      sb.a 'pull-right'
    sb.a '">'

    for i in [1..pageCount]
      if @_pageNum is i
        sb.a '<li class="active">'
        sb.a '<a>' + i + '</a>'
      else
        sb.a '<li>'
        sb.a '<a href="javascript:;" data-cmd="page" data-page="' + i + '">' + i + '</a>'
      sb.a '</li>'

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
