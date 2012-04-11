do (j3) ->
  __calendar_change = (sender, args) ->
    @close()
    @setLabel args.curDate.toString('yyyy-MM-dd')
    @fire 'change', this, oldDate : args.oldDate, curDate : args.curDate

  j3.DateSelector = j3.cls j3.Dropdown,
    cssTrigger : 'icon-calendar'

    onInit : (options) ->
      j3.DateSelector.base().onInit.call this, options

      @_date = options.date

    onCreated : ->
      j3.DateSelector.base().onCreated.call this

      if @_date
        @setLabel @_date.toString('yyyy-MM-dd')

    onCreateDropdownBox : (elBox) ->
      @_calendar = new j3.Calendar ctnr : elBox, date : @_date
      @_calendar.on 'change', this, __calendar_change

    getDate : ->
      @_calendar.getCurrentDate()

