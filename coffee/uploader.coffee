do (j3) ->
  j3.UploadStatus = UploadStatus =
    waiting : 1
    uploading : 2
    succeeded : 4
    failed : 8
    cancelling : 16
    cancelled : 32

  j3.Uploader = Uploader = j3.cls j3.ContainerView,
    baseCss : "uploader"

    onInit : (options) ->
      @_enableDrop = options.enableDrop
      @_actionUrl = options.actionUrl
      @_dropIndicatorText = options.dragIndicatorText
      @_selectLocalIndicatorText = options.selectLocalIndicatorText
      @_removeConfirmText = options.removeConfirmText
      @_autoUpload = options.autoUpload

      # 保存uploadId和form元素之间的映射
      @_formsMap = {}
      # 保存uploadId和file对象之间的映射
      @_filesMap = {}

    createChildren : (options) ->
      @_uploadFileCollection = new j3.Collection
        on :
          addModel : c : this, h : __uploadFileCollection_change
          removeModel : c : this, h : __uploadFileCollection_change
          modelDataChange : c : this, h : __uploadFileCollection_change

      @_uploadFileList = new j3.DataList
        parent : this
        css : 'uploader-file-list'
        datasource : @_uploadFileCollection
        listItemRenderer : options.fileItemRenderer || __uploadFileList_itemRenderer
        on :
          command : c : this, h : __uploadFileList_command
      
    renderChildren : (sb) ->
      sb.a "<div class='uploader-inner'>"
      @_uploadFileList.render sb
      # indicators
      sb.a "<div class='uploader-indicator'>"

      sb.a "<i class='uploader-icon'></i>"

      if @_enableDrop
        sb.a "<span class='uploader-indicator-drop'>"
        sb.a @_dropIndicatorText
        sb.a "</span>"

      sb.a "<a class='uploader-indicator-select uploader-indicator-select-local' href='javascript:;'>"
      sb.a @_selectLocalIndicatorText
      sb.a "</a>"

      sb.a "</div>" # end of uploader-indicator
      sb.a "</div>" # end of uploader-inner

    onCreated : (options) ->
      @_elInner = j3.Dom.firstChild @el
      @_elIndicator = j3.Dom.byIndex @_elInner, 1
      @_elSelectLocal = j3.Dom.byCls @_elIndicator, 'uploader-indicator-select-local'
      j3.on @_elIndicator, 'click', this, __elIndicator_click

      if true or 'draggable' in @el
        @el.ondragover = ->
          return false

        @el.ondragend = ->
          return false

        @el.ondrop = (evt) =>
          __elIndicator_drop.call this, evt

      if j3.UA.ie
        j3.on @_elSelectLocal, 'mouseover', this, __elSelectLocal_mouseover
      else
        j3.on @_elSelectLocal, 'click', this, __elSelectLocal_click

      @setDatasource options.datasource

    onUpdateView : (datasource, eventName, args) ->
      if args and args.changedData and not args.changedData.hasOwnProperty @name then return
      docs = datasource.get @name
      list = []
      if docs
        for eachDoc in docs
          list.push
            id : eachDoc.id
            name : eachDoc.name
            docId : eachDoc.docId || eachDoc.id
            status : eachDoc.status || UploadStatus.succeeded
            progress : eachDoc.progress
      @_uploadFileCollection.loadData list

    reset : ->
      @_formsMap = {}
      @_filesMap = {}
      @_lastFileInput = null
      @_uploadFileCollection.clear()

    upload : ->
      __tryUpload.call this

  j3.ext Uploader.prototype, j3.DataView

  __uploadFileList_itemRenderer = (sb, dataListItem) ->
    data = dataListItem.data

    filename = data.get 'name'
    extname = j3.Path.extname filename
    if extname then extname = extname.substr 1

    links = [
      cmd : 'remove'
      icon : 'icon-remove-doc'
      text : 'remove'
    ]
    linksOptions =
      css : 'action-links pull-right'
      commandMode : true

    j3.LinkList.render links, linksOptions, sb

    sb.a '<div class="pull-right">'
    status = data.get 'status'
    if status is UploadStatus.uploading
      progress = data.get 'progress'
      if not j3.isUndefined progress
        sb.a "#{progress}%"
    sb.a '</div>'

    sb.a '<div class="list-item-title">'
    sb.a '<i class="doc-icon-mini'
    if extname then sb.a ' doc-icon-type-' + extname
    sb.a '"></i>'
    sb.e data.get 'name'
    sb.a '</div>'

  __createUploadIFrame = ->
    if @_elUplaodIFrameCtnr then return

    sb = new j3.StringBuilder

    sb.a "<div style='width:0px;height:0px;overflow:hidden;'>"
    sb.a "<iframe class='uploader-iframe' name='#{@id}-iframe'></iframe>"
    sb.a "</div>"

    j3.Dom.append @_elIndicator, sb.toString()
    @_elUplaodIFrameCtnr = j3.Dom.lastChild @_elIndicator

  __createUploadForm = ->
    __createUploadIFrame.call this

    sb = new j3.StringBuilder

    sb.a "<form class='uploader-form' target='#{@id}-iframe' method='POST' enctype='multipart/form-data'>"
    sb.a "<input type='file' class='uploader-file-input' name='file' multiple='true' title='#{@_selectLocalIndicatorText}' />"
    sb.a "</form>"

    j3.Dom.append @_elUplaodIFrameCtnr, sb.toString()

    form = j3.Dom.lastChild @_elUplaodIFrameCtnr
    elFileInput = j3.Dom.byIndex form, 0
    j3.on elFileInput, 'change', this, __elFileInput_change

    @_lastFileInput = elFileInput
    form

  __elIndicator_click = (evt) ->
    el = evt.src()
    cmd = j3.Dom.data el, 'cmd'

    @fire 'command', this, name : cmd

  # 当鼠标移动到选择本地文件时的处理（针对IE浏览器的处理）
  __elSelectLocal_mouseover = (evt) ->
    if not @_lastFileInput or @_lastFileInput.value
      __createUploadForm.call this

    Dom = j3.Dom
    Dom.opacity @_lastFileInput, 0.01

    src = evt.src()
    pos = Dom.position src
    @_lastFileInput.style.position = 'absolute'
    @_lastFileInput.style.width = src.offsetWidth + 'px'
    @_lastFileInput.style.height = src.offsetHeight + 'px'
    Dom.place @_lastFileInput, pos.left, pos.top

  # 当鼠标点击选择本地文件时的处理（非IE浏览器有效）
  __elSelectLocal_click = (evt) ->
    if not @_lastFileInput or @_lastFileInput.value
      __createUploadForm.call this

    @_lastFileInput.click()

  __elIndicator_drop = (evt) ->
    evt.preventDefault()
    files = event.dataTransfer.files
    if not files then return

    for eachFile in files
      basename = eachFile.name
      uploadId = j3.guid()
      @_uploadFileCollection.insert
        id : uploadId
        name : basename
        status : j3.UploadStatus.waiting
      @_filesMap[uploadId] = eachFile

    if @_autoUpload
      __tryUpload.call this

  # 选择文件后的处理
  __elFileInput_change = (evt) ->
    input = evt.src()
    if not input.value then return

    input.style.position = ''

    if window.FormData
      for eachFile in input.files
        basename = eachFile.name
        uploadId = j3.guid()
        @_uploadFileCollection.insert
          id : uploadId
          name : basename
          status : j3.UploadStatus.waiting
        @_filesMap[uploadId] = eachFile
    else
      basename = j3.Path.basename input.value
      form = input.parentNode
      uploadId = j3.guid()
      @_uploadFileCollection.insert
        id : uploadId
        name : basename
        status : j3.UploadStatus.waiting
      @_formsMap[uploadId] = form

    if @_autoUpload
      __tryUpload.call this

  # 尝试上传文件，如果正在上传则直接返回，否则上传下一个文件
  __tryUpload = ->
    if window.FormData
      __tryUploadByFormData.call this
    else
      __tryUploadByFormSubmit.call this

  __getNextUpload = (map) ->
    if @_uploading is yes then return null

    nextDoc = @_uploadFileCollection.tryUntil (model) ->
      model.get('status') is UploadStatus.waiting

    if not nextDoc then return null
    uploadId = nextDoc.get 'id'

    id : uploadId
    data : map[uploadId]

  __getActionUrl = (uploadId) ->
    callbackName = '__j3UploadCallback'+@id
    action = @_actionUrl || ''
    if j3.indexOf('?') is -1
      action += '?uploadId=' + uploadId
    else
      action += '&uploadId=' + uploadId

    action += '&callback=parent.' + callbackName
    action

  __tryUploadByFormData = ->
    upload = __getNextUpload.call this, @_filesMap
    if not upload then return
    uploadId = upload.id
    uploadFile = upload.data
    if not uploadFile then return

    doc = __getUploadFileById.call this, uploadId
    doc.set 'status', UploadStatus.uploading
    @_uploading = yes

    formData = new FormData
    formData.append 'file', uploadFile
    xhr = new XMLHttpRequest
    action = __getActionUrl.call this, uploadId
    xhr.open 'POST', action
    xhr.setRequestHeader 'Accept', 'application/json'

    xhr.onload = =>
      if xhr.status is 200
        __upload_callback.call this,
          j3.fromJson xhr.responseText
      else
        __upload_callback.call this,
          err : 'Error'
          msg : 'UploadError'
    xhr.upload.onprogress = (evt) =>
      if not event.lengthComputable then return
      progress = (event.loaded / event.total * 100 | 0)
      doc = __getUploadFileById.call this, uploadId
      doc.set 'progress', progress
    xhr.send formData

  __tryUploadByFormSubmit = ->
    upload = __getNextUpload.call this, @_formsMap
    if not upload then return
    uploadId = upload.id
    uploadForm = upload.data
    if not uploadForm then return

    doc = __getUploadFileById.call this, uploadId
    doc.set 'status', UploadStatus.uploading
    @_uploading = yes

    callbackName = '__j3UploadCallback'+@id
    window[callbackName] = (result) =>
      __upload_callback.call this, result

    action = __getActionUrl.call this, uploadId
    uploadForm.action = action
    uploadForm.submit()

  # 根据id获取上传文件模型
  __getUploadFileById = (id) ->
    @_uploadFileCollection.tryUntil (model) ->
      model.get('id') is id

  # 上传完成后的回调处理
  __upload_callback = (data) ->
    @_uploading = false

    doc = __getUploadFileById.call this, data.uploadId
    if not doc then return

    if data.err
      j3.MessageBar.error data.msg
      doc.set 'status', UploadStatus.failed
    else
      doc.set
        status : UploadStatus.succeeded
        docId : data.document._id || data.document.id
      ,
        append : yes

    # 尝试上传下一个文件
    __tryUpload.call this

  # 处理数据绑定
  __uploadFileCollection_change = (sender, args) ->
    if @isUpdatingView() then return

    docs = []
    sender.forEach (eachDoc) ->
      doc = eachDoc.getData()
      if doc.status is UploadStatus.succeeded
        doc.id = doc.docId
      docs.push doc

    @getDatasource().set @name, docs

  __uploadFileList_command = (sender, args) ->
    fileData = args.data

    j3.MessageBox.confirm null, @_removeConfirmText, this, ->
      @_uploadFileCollection.removeById fileData.get 'id'
