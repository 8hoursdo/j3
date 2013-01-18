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
  'queue'
  'compile'
  'enumerate'
  'pool'
  'unique'
  'event-manager'
  'datasource'
  'data-view'
  'model'
  'collection'
  'collection-view'
  'grouped-collection'
]

_filesClient = [
  'json'
  'dom'
  'path'
  'event'
  'dd'
  'http'
  'data-items-view'
  'overlay'
  'view'
  'popup'
  'html-view'
  'container-view'
  'data-list'
  'grouped-data-list'
  'pagination'
  'box-with-arrow'
  'tooltip'
  'button'
  'button-group'
  'checkbox'
  'checkbox-list'
  'textbox'
  'progress-bar'
  'bookmark'
  'calendar'
  'selector'
  'selector-group'
  'dropdown'
  'dropdown-list'
  'dropdown-tree'
  'date-selector'
  'switch'
  'upload-status'
  'upload-selector'
  'uploader'
  'toolbar'
  'form'
  'form-divider'
  'form-item'
  'form-item-group'
  'form-actions'
  'menu-item'
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

module.exports =
  name : 'j3'
  main : 'build-j3'
  steps :
    'build-j3' :
      type : 'sequence'
      steps : [
        'compile-js'
        'compile-less'
        'copy-images'
      ]

    'compile-js' :
      type : 'waterfall'
      steps : [
        'combine-coffee'
        'compile-coffee'
        'compress-js'
      ]

    'combine-coffee' :
      type : 'combine-file'
      inputPath : './coffee'
      inputFileNameFormat : '${fileName}.coffee'
      files :
        'j3.core' : _filesCore
        'j3' : _filesCore.concat _filesClient
        'lang/en-us' : ['lang/en-us']
        'lang/zh-cn' : ['lang/zh-cn']

    'compile-coffee' :
      type : 'compile-coffee'
      writeFile : true
      outputPath : './lib/js'

    'compress-js' :
      type : 'uglify-js'
      writeFile : true
      outputPath : './lib/js'
      outputFileNameFormat : '${fileName}.min.js'

    'compile-less' :
      type : 'compile-less'
      inputPath : './less'
      writeFile : true
      outputPath : './lib/css'
      files : [
        'j3'
      ]

    'copy-images' :
      type : 'copy-file'
      inputPath : './img'
      outputPath : './lib/img'
      files : [
        'icons.png'
        'top-nav-active.gif'
      ]

