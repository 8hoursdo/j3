j3.Dom = do ->
  if j3.isRunInServer() then return null

  UA = j3.UA
  _tempDiv = document.createElement 'div'

  Dom =
    create : (tagName, attributes, innerHTML) ->
      el = document.createElement tagName
      if not el then return

      if not attributes then return el
      for name, value of attributes
        el[name] = value

      if not j3.isUndefined innerHTML
        el.innerHTML = innerHTML

      el

    attr : (el, name, value) ->
      if arguments.length is 3
        el.attributes[name] = value
        return

      node = el.attributes[name]
      if not node then return null
      node.nodeValue

    data : (el, name, value) ->
      if arguments.length is 3
        @attr el, "data-#{name}", value
        return

      if el.dataset
        el.dataset[name]
      else
        @attr el, "data-#{name}"

    hasCls : (el, cls) ->
      j3.include el.className, cls, ' '

    setCls : (el, cls) ->
      el.className = cls.trim()
      return

    addCls : (el, cls) ->
      if !@hasCls el, cls
        el.className = (el.className + ' ' + cls).trim()
      return

    removeCls : (el, cls) ->
      el.className = el.className.replace(new RegExp('(^|\\s)' + cls + '(?:\\s|$)'), '$1').trim()
      return

    replaceCls : (el, cls1, cls2) ->
      if @hasCls el, cls2
        cls2 = ' '
      else
        cls2 = ' ' + cls2 + ' '
      el.className = (' ' + el.className + ' ').replace(' ' + cls1 + ' ', cls2).trim()

      return

    toggleCls : (el, cls1, cls2) ->
      hasCls1 = @hasCls el, cls1
      if arguments.length == 2
        if hasCls1
          @removeCls el, cls1
        else
          @addCls el, cls1
      else
        if hasCls1
          @replaceCls el, cls1, cls2
        else
          @replaceCls el, cls2, cls1

      return

    visible : (el, value) ->
      if arguments.length == 1
        @getStyle el, 'display' != 'none'
      else if value
        @show el
      else
        @hide el

    show : (el) ->
      if el.style.display isnt 'none' then return

      el.style.display = el._oldStyleDisplay || ''
      return

    hide : (el) ->
      if el.style.display is 'none' then return

      el._oldStyleDisplay = el.style.display
      el.style.display = 'none'
      return

    remove : (el) ->
      el.parentNode.removeChild el

    append : (target, el) ->
      if not target then return

      if typeof el is 'string'
        _tempDiv.innerHTML = el
        if _tempDiv.childNodes.length > 1
          els = []
          while _tempDiv.firstChild
            els[els.length] = target.appendChild _tempDiv.firstChild
          return els
        return target.appendChild _tempDiv.firstChild

      target.appendChild el

    parent : (el, selector) ->
      if arguments.length == 1 then return el.parentNode

      if 0 is selector.indexOf '.'
        selector = selector.substr 1
        while el
          if @hasCls el, selector then return el
          el = el.parentNode
      else
        selector = selector.toUpperCase()
        while el
          if el.tagName is selector then return el
          el = el.parentNode
      return null

    indexOf : (el) ->
      p = el.parentNode
      if !p then return -1

      index = 0
      for node in p.childNodes
        if node.nodeType == 1
          if node == el then return index
          ++index
      return -1

    byIndex : (el, index) ->
      if !el then return null
      
      pi = 0
      for node in el.childNodes
        if node.nodeType == 1
          if pi == index then return node
          ++pi
      return null

    byCls : (el, cls) ->
      if !el then return null
      
      for node in el.childNodes
        if node.nodeType == 1
          if @hasCls node, cls then return node
      return null

    firstChild : (el) ->
      el.children[0]

    lastChild : (el) ->
      el = el.lastChild
      while el
        if el.nodeType == 1 then return el
        el = el.previousSibling
      return null

    next : (el) ->
      if !el then return null

      el = el.nextSibling
      while el
        if el.nodeType == 1 then return el
        el = el.nextSibling
      return null

    previous : (el) ->
      if !el then return null

      el = el.previousSibling
      while el
        if el.nodeType == 1 then return el
        el = el.previousSibling
      return null

    pageWidth : (wnd) ->
      wnd ?= window

      pw = wnd.document.documentElement.scrollWidth
      cw = @clientWidth wnd

      if pw > cw then pw else cw

    pageHeight : (wnd) ->
      wnd ?= window

      ph = wnd.document.documentElement.scrollHeight
      ch = @clientHeight wnd

      if ph > ch then ph else ch

    offsetWidth : (el, width) ->
      if arguments.length == 1 then return el.offsetWidth

      if j3.isUndefined(width) or width == -1
        el.style.width = ''
      else
        delta = el.offsetWidth - @width el
        el.style.width = (width - delta) + 'px'
      return

    offsetHeight : (el, height) ->
      if arguments.length == 1 then return el.offsetHeight

      if j3.isUndefined(height) or height == -1
        el.style.height = ''
      else
        delta = el.offsetHeight - @height el
        el.style.height = (height - delta) + 'px'
      return

    place : (el, left, top, clientAbs) ->
      s = el.style
      s.left = s.top = '0'
      pos = @position el, clientAbs

      if not j3.isUndefined left
        s.left = (left - pos.left) + 'px'
      if not j3.isUndefined top
        s.top = (top - pos.top) + 'px'
      return

    center : (el, top, left) ->
      if top isnt 0 then top ?= 0.4
      if left isnt 0 then left ?= 0.5

      cw = @clientWidth()
      ch = @clientHeight()
      ew = @offsetWidth el
      eh = @offsetHeight el
      st = document.documentElement.scrollTop
      sl = document.documentElement.scrollLeft

      if left >= 1
        x = left
      else
        x = (cw - ew)*left + sl

      if top >= 1
        y = top
      else
        y = (ch - eh)*top + st

      if x < 0
        x = 0
      if y < 0
        y = 0
      @place el, x, y

  __width_ie = (el, width) ->
    if arguments.length is 2
      el.style.width = width + 'px'
      return

    cs = el.currentStyle
    borderLeft = parseInt(cs.borderLeftWidth) || 0
    borderRight = parseInt(cs.borderRightWidth) || 0
    paddingLeft = parseInt(cs.paddingLeft) || 0
    paddingRight = parseInt(cs.paddingRight) || 0

    el.offsetWidth - borderLeft - borderRight - paddingLeft - paddingRight

  __height_ie = (el, height) ->
    if arguments.length is 2
      el.style.height = height + 'px'
      return

    cs = el.currentStyle
    borderTop = parseInt(cs.borderTopWidth) || 0
    borderBottom = parseInt(cs.borderBottomWidth) || 0
    paddingTop = parseInt(cs.paddingTop) || 0
    paddingBottom = parseInt(cs.paddingBottom) || 0

    el.offsetHeight - borderTop - borderBottom - paddingTop - paddingBottom

  __width_other = (el, width) ->
    if arguments.length is 2
      el.style.width = width + 'px'
      return

    parseInt document.defaultView.getComputedStyle(el, null).getPropertyValue 'width'

  __height_other = (el, height) ->
    if arguments.length is 2
      el.style.height = height + 'px'
      return

    parseInt document.defaultView.getComputedStyle(el, null).getPropertyValue 'height'

  __position = (el, clientAbs) ->
    if el.parentNode is null or @getStyle(el, 'display') is 'none'
      return null

    box = el.getBoundingClientRect()
    l = box.left
    t = box.top

    if UA.ie and UA.version == 7 and window is top
      l -= 2
      t -= 2

    if not clientAbs
      de = document.documentElement
      l += de.scrollLeft
      t += de.scrollTop

    left : l, top : t

  __position_op_webkit = (el, clientAbs) ->
    if el.parentNode is null or @getStyle(el, 'display') is 'none'
      return null
    
    l = 0
    t = 0

    while el
      l += el.offsetLeft || 0
      t += el.offsetTop || 0

      # for webkit
      if el.offsetParent == document.body and @getStyle(el, 'position') is 'absolute'
        break

      el = el.offsetParent
      if el
        cs = document.defaultView.getComputedStyle(el, null)
        l += parseInt(cs.getPropertyValue 'border-left-width') || 0
        t += parseInt(cs.getPropertyValue 'border-top-width') || 0

    if clientAbs
      de = document.documentElement
      l -= de.scrollLeft
      t -= de.scrollTop

    left : l, top : t

  __opacity_ie = (el, value) ->
    if arguments.length == 1
      # get opacity
      if el.filters.length == 0 then return 1

      filter = el.filters.item 'alpha'
      if !filter
        filter = el.filters.item 'DXImageTransform.Microsoft.Alpha'

      return if filter then filter.opacity / 100 else 1
    else
      # set opacity
      el.style.filter = "alpha(opacity=#{value * 100})"
      if !el.currentStyle.hasLayout
        el.style.zoom = 1
      return

  __opacity_other = (el, value) ->
    if arguments.length == 1
      # get opacity
      return document.defaultView.getComputedStyle(el, '').getPropertyValue 'opacity'
    else
      el.style.opacity = value
      el.style['-moz-opacity'] = value
      el.style['-khtml-opacity'] = value

  __getStyle_ie = (el, styleName) ->
    if styleName is 'opacity'
      @opacity el
    else
      el.currentStyle[styleName]

  __getStyle_other = (el, styleName) ->
    if styleName is 'opacity' then return @opacity el
      
    value = el.style[styleName]
    if value then return value

    document.defaultView.getComputedStyle(el, '').getPropertyValue j3.hyphenlize styleName

  __clientWidth_ie = (wnd) ->
    wnd ?= window
    wnd.document.documentElement.clientWidth

  __clientHeight_ie = (wnd) ->
    wnd ?= window
    wnd.document.documentElement.clientHeight

  __clientWidth_opera = (wnd) ->
    wnd ?= window
    wnd.document.body.clientWidth

  __clientWidth_gecko = (wnd) ->
    wnd ?= window
    wnd.innerWidth

  __clientHeight_gecko = __clientHeight_opera = (wnd) ->
    wnd ?= window
    wnd.innerHeight


  if UA.ie
    j3.ext Dom,
      clientWidth : __clientWidth_ie
      clientHeight : __clientHeight_ie
      width : __width_ie
      height : __height_ie
      position : __position
      getStyle : __getStyle_ie
      opacity : __opacity_ie
  else
    if UA.gecko
      j3.ext Dom,
        clientWidth : __clientWidth_gecko
        clientHeight : __clientHeight_gecko
        position : __position
    else
      j3.ext Dom,
        clientWidth : __clientWidth_opera
        clientHeight : __clientHeight_opera
        position : __position_op_webkit

    j3.ext Dom,
      width : __width_other
      height : __height_other
      getStyle : __getStyle_other
      opacity : __opacity_other

  # detect if we are using IE7 compatible mode in IE8
  if UA.ie && UA.version >= 8 && Dom.position(document.documentElement).left == 2
    UA.version = 7

  Dom

