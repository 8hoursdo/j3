do (j3) ->
  j3.Splitter = j3.cls j3.ContainerView,
    baseCss : 'spt'

    onInit : (options) ->
      if options.vertical then @_vertical = true

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_vertical then ' spt-vertical' else '')

    onCreateChild : (options, args) ->
      options.cls ?= j3.SplitterPanel

    layoutChildren : ->
      if !@children then return

      Dom = j3.Dom

      methodName = if @_vertical then 'height' else 'width'
      autoSize = splitterSize = Dom[methodName].call Dom, @el

      autoSizePanels = []
      node = @children.firstNode()
      while node
        panel = node.value

        # 查找自动调整大小的面板
        panelSize = panel.getSize()
        if panelSize
          panel[methodName].call panel, panel
          autoSize -= panelSize
        else
          autoSizePanels.push panel

        node = node.next

      sizeOfEachAutoPanel = Math.floor autoSize / autoSizePanels.length
      sizeOfLastAutoPanel = autoSize

      for eachAutoSizePanel, i in autoSizePanels
        # 处理四舍五入时产生的误差
        if i is autoSizePanels.length - 1
          panelSize = sizeOfLastAutoPanel
        else
          panelSize = sizeOfEachAutoPanel
          sizeOfLastAutoPanel -= sizeOfEachAutoPanel
        
        eachAutoSizePanel[methodName].call eachAutoSizePanel, panelSize

      return

