do (j3) ->
  j3.SplitterPanel = j3.cls j3.ContainerView,
    baseCss : 'spt-pnl'

    onInit : (options) ->
      # 填充方式由splitter来决定
      @_fill = 0
      @_size = options.size || 0

    getSize : ->
      @_size
