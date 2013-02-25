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

      # 上传队列
      @_uploadQueue = options.uploadQueue

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

    canTriggerFileSelect : ->
      !!window.FormData

    triggerFileSelect : ->
      if not @_lastFileInput or @_lastFileInput.value
        __createUploadForm.call this

      @_lastFileInput.click()

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
    @triggerFileSelect()

  # 选择文件后的处理
  __elFileInput_change = (evt) ->
    input = evt.src()
    if not input.value then return

    input.style.position = ''

    if window.FormData
      for eachFile in input.files
        basename = eachFile.name
        uploadId = j3.guid()
        uploadInfo =
          id : uploadId
          name : basename
          contextData : @_contextData
          status : j3.UploadStatus.waiting
          uploadUrl : @_uploadUrl
          passFileNameInActionUrl : @_passFileNameInActionUrl
          file : eachFile
        @_uploadQueue.addUpload uploadInfo
    else
      basename = j3.Path.basename input.value
      form = input.parentNode
      uploadId = j3.guid()
      uploadModel = @_uploadFileCollection.insert
        id : uploadId
        name : basename
        contextData : @_contextData
        status : j3.UploadStatus.waiting
        uploadUrl : @_uploadUrl
        passFileNameInActionUrl : @_passFileNameInActionUrl
        form : form
      @_uploadQueue.addUpload uploadInfo
    return

