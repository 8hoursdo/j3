fs = require 'fs'
coffeescript = require 'coffee-script'

_filesCore = [
  'j3'
  'oo'
  'user-agent'
  'string-builder'
  'url-query'
  'date-time'
  'string'
  'template'
  'list'
  'compile'
  'enumerate'
  'pool'
  'event-manager'
  'datasource'
  'data-view'
  'model'
  'collection'
  'collection-view'
]

_filesClient = [
  'json'
  'dom'
  'event'
  'http'
  'data-items-view'
  'overlay'
  'view'
  'popup'
  'container-view'
  'data-list'
  'button'
  'button-group'
  'checkbox'
  'textbox'
  'progress-bar'
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

task 'build', 'build j3 libarary', (options) ->
  __build _filesCore, 'j3.core'
  __build _filesCore.concat(_filesClient), 'j3'
  __buildLangFiles()

__build = (coffeeFiles, outputFileName) ->
  coffeeDir = __dirname + '/coffee'
  outputDir = __dirname + '/lib'

  fs.mkdir outputDir

  scriptContent = []
  for eachFile in coffeeFiles
    filename = "#{coffeeDir}/#{eachFile}.coffee"
    scriptContent.push fs.readFileSync filename, 'utf-8'
    scriptContent.push '\n'
  output = coffeescript.compile scriptContent.join ''

  fs.mkdir outputDir + '/js'
  outputFile = "#{outputDir}/js/#{outputFileName}.js"
  fs.writeFile outputFile, output
  console.log "builded: #{outputFile}"
  
# build lang files
__buildLangFiles = ->
  coffeeDir = __dirname + '/coffee'
  outputDir = __dirname + '/lib'

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
