task 'build', 'build j3 libarary', (options) ->
  coffeeDir = __dirname + '/coffee'
  outputDir = __dirname + '/build'
  coffeeFiles = [
    'j3'
    ,'oo'
    ,'user-agent'
    ,'string-builder'
    ,'dom'
    ,'list'
    ,'event-manager'
    ,'view'
  ]

  fs = require 'fs'
  coffeescript = require 'coffee-script'
  scriptContent = []
  for eachFile in coffeeFiles
    filename = "#{coffeeDir}/#{eachFile}.coffee"
    scriptContent.push fs.readFileSync filename, 'utf-8'
  output = coffeescript.compile scriptContent.join ''
  
  outputFile = "#{outputDir}/js/j3.js"
  fs.writeFile outputFile, output
  console.log "builded: #{outputFile}"
