do (j3) ->
  __calendar_change = (sender, args) ->
    if @isUpdatingSubcomponent() then return

    @close()
    @setDate args.curDate

  j3.DateSelector = j3.cls j3.Dropdown,
    cssTrigger : 'icon-calendar'

    onInit : (options) ->
      j3.DateSelector.base().onInit.call this, options

      @_name = options.name

    onCreated : (options) ->
      j3.DateSelector.base().onCreated.call this

      @setDate options.date
      @setDatasource options.datasource

    onCreateDropdownBox : (elBox) ->
      @_calendar = new j3.Calendar ctnr : elBox, date : @_date
      @_calendar.on 'change', this, __calendar_change

    getDate : ->
      @_calendar.getCurrentDate()

    setDate : (date, internal) ->
      if j3.equals @_date, date then return

      oldDate = @_date
      @_date = date

      unless internal
        if @_date
          selectedItem =
            text : @_date.toString 'yyyy-MM-dd'
            value : @_date

        @doSetSelectedItems selectedItem

      @updateData()
      @fire 'change', this, oldDate : oldDate, curDate : @_date

    onSetSelectedItems : ->
      selectedItem = @getSelectedItem()
      @setDate (selectedItem && selectedItem.value) || null, true
      @updateSubcomponent()

    onUpdateData : ->
      @_datasource.set @_name, @_date

    onUpdateView : ->
      @setDate @_datasource.get @_name
      @updateSubcomponent()

    onUpdateSubcomponent : ->
      if @_calendar then @_calendar.setCurrentDate @_date

  j3.ext j3.DateSelector.prototype, j3.DataView
