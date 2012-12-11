do (j3) ->
  j3.MenuItem = MenuItem = j3.cls j3.View,
    baseCss : 'menu-item'

    onInit : (options) ->
      @_text = options.text || ''
      @_url = options.url
      @_items = options.items || []

  MenuItem.render = (sb, options) ->
    css = 'menu-item'
    if options.divider
      css += ' menu-divider'

    sb.a '<li class="' + css + '">'
    sb.a '<a'
    if options.url
      sb.a ' href="' + options.url + '"'

    sb.a ' data-cmd="'
    sb.a options.name || ''
    sb.a '">'

    sb.a '<i'
    if options.icon
      sb.a 'class="' + options.icon + '"'
    sb.a '></i>'
  
    sb.e options.text || ''

    sb.a '</li>'
