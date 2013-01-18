do (j3) ->
  UploadStatus = j3.UploadStatus

  j3.UploadSelector = UploadSelector = j3.cls j3.ContainerView,
    baseCss : "upload-selector"

    onInit : (options) ->
      # 是否允许选择多个文件
      @_multiple = options.multiple

      # 文件上传的目标地址
      @_uploadUrl = options.uploadUrl

      # 是否在上传的地址中传递文件名
      @_passFileNameInActionUrl = options.passFileNameInActionUrl

      # 是否在选择文件后自动上传
      @_autoUpload = options.autoUpload

      # 上下文信息。例如，可以通过此选项设置要将文件上传到哪个文件夹
      @_contextData = options.contextData

      # 保存uploadId和form元素之间的映射
      @_formsMap = {}
      # 保存uploadId和file对象之间的映射
      @_filesMap = {}

      # 保存激活文件选择的触发器
      @_triggers = []

    createChildren : (options) ->
      @_uploadFileCollection = new j3.Collection
      
    renderChildren : (sb) ->

    onCreated : (options) ->
      if options.trigger
        @registerTrigger options.trigger

    reset : ->
      @_formsMap = {}
      @_filesMap = {}
      @_lastFileInput = null
      @_uploadFileCollection.clear()

    upload : ->
      __tryUpload.call this

    getUploading : ->
      @_uploading

    getLastFileInput : ->
      @_lastFileInput

    registerTrigger : (trigger) ->
      if j3.in @_triggers, trigger then return
      if j3.UA.ie
        j3.on trigger, 'mouseover', this, __elSelectLocal_mouseover
      else
        j3.on trigger, 'click', this, __elSelectLocal_click
      @_triggers.push trigger

    unregisterTrigger : (trigger) ->
      if not j3.in @_triggers, trigger then return
      if j3.UA.ie
        j3.on trigger, 'mouseover', this, __elSelectLocal_mouseover
      else
        j3.on trigger, 'click', this, __elSelectLocal_click
      j3.remove @_triggers, trigger

    getUploadUrl : ->
      @_uploadUrl

    setUploadUrl : (value) ->
      @_uploadUrl = value

    setContextData : (value) ->
      @_contextData = value

  __createUploadIFrame = ->
    if @_elUplaodIFrameCtnr then return

    sb = new j3.StringBuilder

    sb.a "<div style='width:0px;height:0px;overflow:hidden;'>"
    sb.a "<iframe class='uploader-iframe' name='#{@id}-iframe'></iframe>"
    sb.a "</div>"

    j3.Dom.append @el, sb.toString()
    @_elUplaodIFrameCtnr = j3.Dom.lastChild @el

  __createUploadForm = ->
    __createUploadIFrame.call this

    sb = new j3.StringBuilder

    sb.a "<form class='uploader-form' target='#{@id}-iframe' method='POST' enctype='multipart/form-data'>"
    sb.a "<input type='file' class='uploader-file-input' name='file'"
    if @_multiple
      sb.a " multiple='true'"
    sb.a " title='#{@_tip}' />"
    sb.a "</form>"

    j3.Dom.append @_elUplaodIFrameCtnr, sb.toString()

    form = j3.Dom.lastChild @_elUplaodIFrameCtnr
    elFileInput = j3.Dom.byIndex form, 0
    j3.on elFileInput, 'change', this, __elFileInput_change

    @_lastFileInput = elFileInput
    form

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
          contextData : @_contextData
          status : j3.UploadStatus.waiting
        @_filesMap[uploadId] = eachFile
    else
      basename = j3.Path.basename input.value
      form = input.parentNode
      uploadId = j3.guid()
      @_uploadFileCollection.insert
        id : uploadId
        name : basename
        contextData : @_contextData
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

  __getActionUrl = (uploadInfo) ->
    callbackName = '__j3UploadCallback'+@id
    action = @_uploadUrl || ''

    uploadId = j3.getVal uploadInfo, 'id'
    if j3.indexOf('?') is -1
      action += '?uploadId=' + uploadId
    else
      action += '&uploadId=' + uploadId

    if @_passFileNameInActionUrl
      action += "&fileName=#{encodeURIComponent(j3.getVal uploadInfo, 'name', '')}"

    contextData = j3.getVal uploadInfo, 'contextData'
    if contextData
      for key, val of contextData
        action += "&#{key}=#{encodeURIComponent val}"

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
    @fire 'uploadStatusChange', this, data : doc

    formData = new FormData
    formData.append 'file', uploadFile
    xhr = new XMLHttpRequest
    action = __getActionUrl.call this, doc
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
    @fire 'uploadStatusChange', this, data : doc

    callbackName = '__j3UploadCallback'+@id
    window[callbackName] = (result) =>
      __upload_callback.call this, result

    action = __getActionUrl.call this, doc
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

    @fire 'uploadStatusChange', this, data : doc

    # 尝试上传下一个文件
    __tryUpload.call this


