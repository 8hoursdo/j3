do (j3) ->
  UploadStatus = j3.UploadStatus

  j3.UploadQueue = UploadQueue = j3.cls
    ctor : (options) ->
      @id = j3.View.genId()

      # 是否在选择文件后自动上传
      @_autoUpload = options.autoUpload

      # 保存uploadId和form元素之间的映射
      @_formsMap = {}
      # 保存uploadId和file对象之间的映射
      @_filesMap = {}

      @_uploadFileCollection = new j3.Collection

      options.on && @on options.on
      return

    upload : ->
      __tryUpload.call this

    getUploading : ->
      @_uploading

    addUpload : (uploadInfo) ->
      uploadModel = @_uploadFileCollection.insert j3.clone uploadInfo, ['id', 'name', 'contextData', 'status', 'uploadUrl', 'passFileNameInActionUrl'], true
      if uploadInfo.file
        @_filesMap[uploadInfo.id] = uploadInfo.file
      else if uploadInfo.form
        @_formsMap[uploadInfo.id] = uploadInfo.form

      @fire 'uploadAdd', this, data : uploadModel
      if @_autoUpload
        __tryUpload.call this

  j3.ext UploadQueue.prototype, j3.EventManager

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
    action = j3.getVal(uploadInfo, 'uploadUrl') || ''

    uploadId = j3.getVal uploadInfo, 'id'
    if j3.indexOf('?') is -1
      action += '?uploadId=' + uploadId
    else
      action += '&uploadId=' + uploadId

    if j3.getVal(uploadInfo, 'passFileNameInActionUrl')
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
      @fire 'uploadProgressChange', this, data : doc
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
      updateData =
        status : UploadStatus.succeeded
      if data.document
        updateData.docId = data.document._id || data.document.id
      doc.set updateData
      ,
        append : yes

    @fire 'uploadStatusChange', this, data : doc

    # 尝试上传下一个文件
    __tryUpload.call this


