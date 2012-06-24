task 'build', 'build j3 libarary', (options) ->
  coffeeDir = __dirname + '/coffee'
  outputDir = __dirname + '/lib'
  coffeeFiles = [
    'j3'
    'oo'
    'user-agent'
    'string-builder'
    'url-query'
    'date-time'
    'string'
    'template'
    'dom'
    'list'
    'enumerate'
    'pool'
    'json'
    'event'
    'event-manager'
    'http'
    'datasource'
    'data-view'
    'data-items-view'
    'compile'
    'model'
    'collection'
    'collection-view'
    'overlay'
    'view'
    'popup'
    'container-view'
    'data-list'
    'button'
    'button-group'
    'checkbox'
    'textbox'
    'calendar'
    'selector'
    'dropdown'
    'dropdown-list'
    'dropdown-tree'
    'date-selector'
    'switch'
    'toolbar'
    'form'
    'form-divider'
    'form-item'
    'form-actions'
    'menu'
    'navbar'
    'link-list'
    'nav-group'
    'panel'
    'tabset'
    'tab-panel'
    'tree-node'
    'tree-view'
    'window-actions'
    'window'
    'message-box'
    'message-bar'
    'splitter'
    'splitter-panel'
    'location'
    'router'
    'application'
    'page'
  ]

  fs = require 'fs'
  fs.mkdir outputDir

  coffeescript = require 'coffee-script'
  scriptContent = []
  for eachFile in coffeeFiles
    filename = "#{coffeeDir}/#{eachFile}.coffee"
    scriptContent.push fs.readFileSync filename, 'utf-8'
    scriptContent.push '\n'
  output = coffeescript.compile scriptContent.join ''

  fs.mkdir outputDir + '/js'
  outputFile = "#{outputDir}/js/j3.js"
  fs.writeFile outputFile, output
  console.log "builded: #{outputFile}"
  
  # build lang files
  fs.mkdir outputDir + '/js/lang'
  langFiles = [
    'zh-cn'
    'en-us'
  ]
  for eachFile in langFiles
    filename = "#{coffeeDir}/lang/#{eachFile}.coffee"
    content = fs.readFileSync filename, 'utf-8'
    outputFile = "#{outputDir}/js/lang/#{eachFile}.js"
    fs.writeFile outputFile, coffeescript.compile content, bare:true
    console.log "builded: #{outputFile}"
