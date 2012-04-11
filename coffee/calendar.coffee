j3.Calendar = do ->
  __getFirstDateOfMonthView = (year, month, firstDayOfWeek) ->
    startDate = new j3.DateTime year, month, 1
    startDate = startDate.addDay 0 - startDate.getDayOfWeek() + firstDayOfWeek
    if startDate.getMonth() == month && startDate.getDay() > 1
      startDate = startDate.addDay -7
    startDate

  __monthViewClick = (evt) ->
    el = evt.src()
    if el.tagName != 'A' then return

    clickedCell = el.parentNode
    rowIndex = clickedCell.parentNode.rowIndex
    cellIndex = clickedCell.cellIndex

    clickedDate = @_firstDateOfMonthView.addDay (rowIndex - 1) * 7 + cellIndex
    @setCurrentDate clickedDate

  Calendar = j3.cls j3.View,
    onInit : (options) ->
      options.firstDayOfWeek ?= 1
      @_firstDayOfWeek = options.firstDayOfWeek % 7
      @_date = options.date

      today = j3.DateTime.today()
      if options.year
        @_year = options.year
      else if @_date
        @_year = @_date.getYear()
      else
        @_year = today.getYear()

      if options.month
        @_month = options.month
      else if @_date
        @_month = @_date.getMonth()
      else
        @_month = today.getMonth()
      return

    render : (buffer) ->
      buffer.append '<div id="' + @id + '" class="cld">'
      buffer.append '<div class="cld-top">'
      buffer.append '<a class="cld-next-month"></a>'
      buffer.append '<a class="cld-prev-month"></a>'
      buffer.append '<div class="cld-cur-year-month"></div>'
      buffer.append '</div>'
      buffer.append '<div class="cld-month-view">'
      @renderMonthView buffer
      buffer.append '</div>'
      buffer.append '</div>'
      return

    renderMonthView : (buffer) ->
      buffer.append '<table><tr>'

      # render names of week day
      for i in [0...7]
        dayOfWeek = (@_firstDayOfWeek + i) % 7
        buffer.append '<th class="cld-weekday-"' + dayOfWeek + '>' + j3.Lang.dayNameAbb[dayOfWeek] + '</th>'
      buffer.append '</tr>'

      # render days of month
      today = j3.DateTime.today()

      # the first displayed date of calendar
      @_firstDateOfMonthView = __getFirstDateOfMonthView @_year, @_month, @_firstDayOfWeek
      @_lastDateOfMonthView = @_firstDateOfMonthView.addDay 42

      renderingDate = @_firstDateOfMonthView
      for i in [0...6]
        buffer.append '<tr>'
        for j in [0...7]
          isCurDate = renderingDate.equals @_date
          buffer.append '<td class="'
          
          buffer.append 'cld-weekday-' + renderingDate.getDayOfWeek()
          if renderingDate.equals today
            buffer.append ' cld-today'
          if isCurDate
            buffer.append ' active'
          buffer.append '"><a>' + renderingDate.getDay() + '</a></td>'
          renderingDate = renderingDate.addDay 1

        buffer.append '</tr>'

      buffer.append '</table>'
      return

    onCreated : ->
      Dom = j3.Dom
      @_elCldTop = Dom.firstChild @el
      @_elNextMonth = Dom.firstChild @_elCldTop
      @_elPrevMonth = Dom.next @_elNextMonth
      @_elCurYearMonth = Dom.next @_elPrevMonth

      @_elMonthView = Dom.next @_elCldTop


      j3.on @_elMonthView, 'click', this, __monthViewClick

      j3.on @_elPrevMonth, 'click', this, ->
        @_month--
        if @_month == 0
          @_year--
          @_month = 12
        @refreshMonthView()
        @_elCurYearMonth.innerHTML = @_year + ' - ' + @_month

      j3.on @_elNextMonth, 'click', this, ->
        @_month++
        if @_month == 13
          @_year++
          @_month = 1
        @refreshMonthView()
        @_elCurYearMonth.innerHTML = @_year + ' - ' + @_month

      @_elCurYearMonth.innerHTML = @_year + ' - ' + @_month
    
    refreshMonthView : ->
      buffer = new j3.StringBuilder
      @renderMonthView buffer
      @_elMonthView.innerHTML = buffer.toString()

    getCurrentDate : ->
      @_date

    setCurrentDate : (date) ->
      if j3.DateTime.equals @_date, date then return

      oldDate = @_date
      @_date = date

      @refreshMonthView()
      @fire 'change', this, oldDate : oldDate, curDate : date
      
  Calendar
