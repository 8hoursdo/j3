j3.Selector = j3.cls j3.View,
  baseCss : 'sel'

  template : j3.template '<div id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><div class="sel-lbl"></div><input type="text" class="sel-txt" /><a class="sel-trigger"><i class="<%=cssTrigger%>"></i></a></div>'

  onInit : (options) ->
    @_disabled = !!options.disabled

  onCreated : () ->
    @_elLabel = j3.Dom.byIndex @el, 0
    @_elText = j3.Dom.next @_elLabel
    @_elTrigger = j3.Dom.next @_elText

    j3.on @_elTrigger, 'click', =>
      @onTriggerClick && @onTriggerClick()

  getTemplateData : ->
    id : @id
    css : @getCss() +
      (if @_disabled then ' disabled' else '')
    cssTrigger : @cssTrigger
    disabled : @_disabled

  getDisabled : ->
    @_disabled

  setDisabled : (value) ->
    @_disabled = !!value
    j3.Dom.toggleCls @el, 'disabled'

  setLabel : (html) ->
    @_elLabel.innerHTML = html

  setText : (text) ->
    @_elText.value = text

  onSetWidth : (width) ->
    Dom = j3.Dom
    widthLabel = Dom.offsetWidth @_elLabel
    widthCur = Dom.offsetWidth @el
    Dom.offsetWidth @_elLabel, widthLabel + width - widthCur

