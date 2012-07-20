do(j3) ->
  __getPercentage = (options) ->
    Math.floor(options.value * 100 / (options.max - options.min))

  __getIndicateText = (options) ->
    switch options.indicator
      when 'none' then ''
      when 'percentage' then options.percentage + '%'
      when 'progress' then options.value + ' / ' + options.max
      when 'text'
        if options.percentage is 0
          text = options.preparingText
        else if options.percentage is 100
          text = options.completedText
        else
          text = options.processingtext
        j3.htmlEncode text

  __refresh = ->
    options =
      min : @_min
      max : @_max
      value : @_value
      preparingText : @_preparingText
      processingtext : @_processingtext
      completedText : @_completedText
      indicator : @_indicator

    options.percentage = __getPercentage options
    text = __getIndicateText options

    @_elBg.innerHTML = text
    @_elText.innerHTML = text

    undonePercentage = 100 - options.percentage

    @_elInner.style.marginLeft = '-' + undonePercentage + '%'
    @_elDone.style.marginLeft = undonePercentage + '%'
    @_elText.style.marginLeft = undonePercentage + '%'

  j3.ProgressBar = ProgressBar = j3.cls j3.View,
    baseCss : 'prg-bar'

    onInit : (options) ->
      @_min = options.min || 0
      @_max = options.max || 100
      @_value = options.value || 0

      # 表示应该如何显示指示文本
      # 可以是 none, percentage, progress, text。默认为percentage。
      @_indicator = options.indicator || 'percentage'

      # 当indicator为text时，进度条上显示的文字
      @_preparingText = options.preparingText
      @_processingtext = options.processingText
      @_completedText = options.completedText

      @_inline = options.inline

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_inline then ' prg-bar-inline' else '')

    onRender : (sb, data) ->
      ProgressBar.render sb,
        id : data.id
        css : data.css
        min : @_min
        max : @_max
        value : @_value
        preparingText : @_preparingText
        processingtext : @_processingtext
        completedText : @_completedText
        indicator : @_indicator

    onCreated : ->
      Dom = j3.Dom
      @_elBg = Dom.firstChild @el
      @_elInner = Dom.next @_elBg
      @_elDone = Dom.firstChild @_elInner
      @_elText = Dom.next @_elDone

    getMin : ->
      @_min

    setMin : (value) ->
      @_min = value
      __refresh.call this

    getMax : ->
      @_max

    setMax : (value) ->
      @_max = value
      __refresh.call this

    getValue : ->
      @_value

    setValue : (value) ->
      @_value = value
      __refresh.call this

    getPercentage : ->
      __getPercentage min : @_min, max : @_max, value : @_value

  ProgressBar.render = (sb, options) ->
    options.css ?= 'prg-bar'
    options.indicator ?= 'percentage'
    options.min ?= 0
    options.max ?= 100
    options.value ?= 0

    options.percentage = __getPercentage options
    text = __getIndicateText options

    sb.a '<div class="' + options.css + '"'

    if options.id
      sb.a ' id="' + options.id + '"'

    sb.a '>'
    sb.a '<div class="prg-bar-bg">'
    sb.a text
    sb.a '</div>'

    undonePercentage = 100 - options.percentage

    sb.a '<div class="prg-bar-inner" style="margin-left:-'
    sb.a undonePercentage
    sb.a '%">'

    sb.a '<div class="prg-bar-done" style="margin-left:'
    sb.a undonePercentage
    sb.a '%"></div>'

    sb.a '<div class="prg-bar-text" style="margin-left:'
    sb.a undonePercentage
    sb.a '%">'
    sb.a text
    sb.a '</div>' # end of prg-bar-text

    sb.a '</div>' # end of prg-bar-done

    sb.a '</div>' # end of prg-bar
      
