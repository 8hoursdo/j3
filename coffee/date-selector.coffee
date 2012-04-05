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
    @_calendar.on 'change', (sender, args) =>
      @setLabel args.curDate.toString('yyyy-MM-dd')
      @close()
    
