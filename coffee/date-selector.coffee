do (j3) ->
  __calendar_change = (sender, args) ->
    @close()
    @setDate args.curDate
    
  j3.DateSelector = j3.cls j3.Dropdown,
    cssTrigger : 'icon-calendar'

    onInit : (options) ->
      j3.DateSelector.base().onInit.call this, options

      @_name = options.name
      @_date = options.date

    onCreated : (options) ->
      j3.DateSelector.base().onCreated.call this

      if @_date
        @setLabel @_date.toString 'yyyy-MM-dd'

      @setDatasource options.datasource

    onCreateDropdownBox : (elBox) ->
      @_calendar = new j3.Calendar ctnr : elBox, date : @_date
      @_calendar.on 'change', this, __calendar_change

    getDate : ->
      @_calendar.getCurrentDate()

    setDate : (date) ->
      if j3.equals @_date, date then return

      oldDate = @_date
      @_date = date
      if @_date
        @setLabel @_date.toString 'yyyy-MM-dd'

      @updateData()
      @fire 'change', this, oldDate : oldDate, curDate : @_date

    onUpdateData : ->
      @_datasource.set @_name, @_date
      
    onUpdateView : ->
      @setDate @_datasource.get @_name
  
  j3.ext j3.DateSelector.prototype, j3.DataView
