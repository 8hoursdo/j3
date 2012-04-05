task 'build', 'build j3 libarary', (options) ->
  coffeeDir = __dirname + '/coffee'
  outputDir = __dirname + '/j3'
  coffeeFiles = [
    'j3'
    ,'oo'
    ,'user-agent'
    ,'string-builder'
    ,'date-time'
    ,'string'
    ,'dom'
    ,'list'
    ,'event'
    ,'event-manager'
    ,'view'
    ,'container-view'
    ,'button'
    ,'textbox'
    ,'calendar'
    ,'selector'
    ,'dropdown'
    ,'dropdown-list'
    ,'date-selector'
  ]

  fs = require 'fs'
  coffeescript = require 'coffee-script'
  scriptContent = []
  for eachFile in coffeeFiles
    filename = "#{coffeeDir}/#{eachFile}.coffee"
    scriptContent.push fs.readFileSync filename, 'utf-8'
  output = coffeescript.compile scriptContent.join ''
  
  fs.mkdir outputDir + '/coffee'
  outputFile = "#{outputDir}/coffee/j3.coffee"
  fs.writeFile outputFile, scriptContent

  fs.mkdir outputDir + '/js'
  outputFile = "#{outputDir}/js/j3.js"
  fs.writeFile outputFile, output
  console.log "builded: #{outputFile}"
  
  # build lang files
  fs.mkdir outputDir + '/js/lang'
  langFiles = [
    'zh-cn'
    ,'en-us'
  ]
  for eachFile in langFiles
    filename = "#{coffeeDir}/lang/#{eachFile}.coffee"
    content = fs.readFileSync filename, 'utf-8'
    outputFile = "#{outputDir}/js/lang/#{eachFile}.js"
    fs.writeFile outputFile, coffeescript.compile content, bare:true
    console.log "builded: #{outputFile}"
