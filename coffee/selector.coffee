j3.Selector = j3.cls j3.View,
  template : _.template '<div id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><div class="sel-lbl"></div><input type="text" class="sel-txt" /><a class="sel-trigger"><i class="<%=cssTrigger%>"></i></a></div>'

  onInit : (options) ->
    @_disabled = !!options.disabled

  onCreated : () ->
    @_elLabel = @el.find('.sel-lbl')
    @_elText = @el.find('.sel-txt')

  getViewData : ->
    id : @id
    css : 'sel' +
      (if @_disabled then ' disabled' else '')
    cssTrigger : @cssTrigger
    disabled : @_disabled

  getDisabled : ->
    @_disabled

  setDisabled : (value) ->
    @_disabled = !!value
    @el.toggleClass 'disabled'

  setLabel : (html) ->
    @_elLabel.html html

  setText : (text) ->
    @_elText.attr 'value', text

