do(j3) ->
  j3.Bookmark = {}

  j3.Bookmark.render = (sb, options) ->
    baseCss = 'bookmark'
    css = baseCss

    if options.gray
      css += ' ' + baseCss + '-gray'

    if options.warning
      css += ' ' + baseCss + '-warning'

    if options.danger
      css += ' ' + baseCss + '-danger'

    if options.icon
      css += ' ' + baseCss + '-with-icon'

    if options.iconGray
      css += ' ' + baseCss + '-with-icon-gray'

    if options.iconWarning
      css += ' ' + baseCss + '-with-icon-warning'

    if options.iconDanger
      css += ' ' + baseCss + '-with-icon-danger'

    if options.css
      css += ' ' + css

    sb.a '<div'
    if options.id
      sb.a ' id="' + options.id + '"'
    sb.a ' class="' + css + '">'

    if options.icon
      sb.a '<span class="bookmark-icon"><i class="'
      sb.a options.icon
      sb.a '"></i></span>'

    sb.a '<span class="bookmark-label">'
    sb.e options.text
    sb.a '</span>'

    sb.a '<span class="bookmark-shadow"></span>'

    sb.a '</div>'
