j3.DateTime = do ->
  _SECOND =  1000
  _MINUTE =  60000
  _HOUR =    3600000
  _DAY =     86400000

  _monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  # parse date time like this: 2008-12-31 18:08:08
  _regParse1 = /^(\d{4})-(\d{1,2})-(\d{1,2})(?: (\d{1,2}):(\d{1,2}):(\d{1,2})(?:.(\d{1,3}))?)?$/
  # parse date time like this: 12/31/2008 18:08:08
  _regParse2 = /^(\d{1,2})\/(\d{1,2})\/(\d{4})(?: (\d{1,2}):(\d{1,2}):(\d{1,2})(?:.(\d{1,3}))?)?$/
  # parse date time like this: 2008-12-31T18:08:08.000Z
  _regParseUTC = /^(\d{4})-(\d{1,2})-(\d{1,2})(?:T(\d{1,2}):(\d{1,2}):(\d{1,2})(?:.(\d{1,3}))?)?Z$/

  _FORMAT_LOACL = 'yyyy-MM-dd HH:mm:ss'
  _FORMAT_UTC = 'yyyy-MM-ddTHH:mm:ssZ'

  # class members of DateTime
  DateTime = j3.cls
    ctor : (year, month, date, hours, minutes, seconds, ms) ->
      argLen = arguments.length
      if argLen == 0
        @_value = new Date
      else if argLen == 1
        @_value = new Date year
      else
        month = month || 0
        date = date || 0
        hours = hours || 0
        minutes = minutes || 0
        seconds = seconds || 0
        ms = ms || 0
        @_value = new Date year, (month - 1), date, hours, minutes, seconds, ms
      return

    getYear : ->
      @_value.getFullYear()

    getMonth : ->
      @_value.getMonth() + 1

    getDay : ->
      @_value.getDate()

    getDayOfWeek : ->
      @_value.getDay()

    justDate : ->
      new DateTime @getYear(), @getMonth(), @getDay()

    justTime : ->
      new DateTime @_value.getTime() % _DAY

    addYear : (years) ->
      new DateTime @_value.getFullYear + years
        , @_value.getMonth() + 1
        , @_value.getDate()
        , @_value.getHours()
        , @_value.getMinutes()
        , @_value.getSeconds()
        , @_value.getMilliseconds()

    addMonth : (months) ->
      month = @_value.getFullYear() * 12 + @_value.getMonth() + 1 + months
      year = parseInt month / 12
      month %= 12
      new DateTime year
        , month
        , @_value.getDate()
        , @_value.getHours()
        , @_value.getMinutes()
        , @_value.getSeconds()
        , @_value.getMilliseconds()

    addDay : (days) ->
      new DateTime @_value.getTime() + _DAY * days

    addHour : (hours) ->
      new DateTime @_value.getTime() + _HOUR * hours

    addMinute : (minutes) ->
      new DateTime @_value.getTime() + _MINUTE * minutes

    addSecond : (seconds) ->
      new DateTime @_value.getTime() + _SECOND * seconds

    toString : (format) ->
      format ?= _FORMAT_LOACL
      DateTime.format @_value, format

    toUTCString : ->
      DateTime.format @_value, _FORMAT_UTC, yes

    toJson : (buffer) ->
      if j3.isUndefined buffer
        buffer = new j3.StringBuilder
      buffer.append '"'
      buffer.append @toUTCString()
      buffer.append '"'
      

    getValue : ->
      new Date @_value.getTime()

    getTime : ->
      @_value.getTime()

    equals : (dateTime) ->
      if !dateTime then return false
      @_value.getTime() is dateTime._value.getTime()

    clone : ->
      new DateTime @_value.getTime()
      
  j3.ext DateTime,
    UTC : (year, month, date, hours, minutes, seconds, ms) ->
      argLen = arguments.length
      if argLen == 0
        time = (new Date).getTime()
      else if argLen == 1
        time = year
      else
        month = month || 0
        date = date || 0
        hours = hours || 0
        minutes = minutes || 0
        seconds = seconds || 0
        ms = ms || 0
        time = Date.UTC(year, (month - 1), date, hours, minutes, seconds, ms)
      new DateTime time

    format : (value, format, isUTC) ->
      if value instanceof DateTime
        value = value.getValue()
      if typeof value is 'number'
        value = new Date value
      else if not value instanceof Date
        return ''

      format ?= _FORMAT_LOACL

      if isUTC
        strYear = value.getUTCFullYear().toString()
        strMonth = (value.getUTCMonth() + 1).toString()
        strDay = value.getUTCDate().toString()
        strHour = value.getUTCHours().toString()
        strMinute = value.getUTCMinutes().toString()
        strSecond = value.getUTCSeconds().toString()
      else
        strYear = value.getFullYear().toString()
        strMonth = (value.getMonth() + 1).toString()
        strDay = value.getDate().toString()
        strHour = value.getHours().toString()
        strMinute = value.getMinutes().toString()
        strSecond = value.getSeconds().toString()

      str = format.replace 'yyyy', strYear
      str = str.replace 'MMM', _monthNames[value.getMonth()]
      str = str.replace 'MM', if strMonth.length == 1 then '0' + strMonth else strMonth
      str = str.replace 'dd', if strDay.length == 1 then '0' + strDay else strDay
      str = str.replace 'HH', if strHour.length == 1 then '0' + strHour else strHour
      str = str.replace 'mm', if strMinute.length == 1 then '0' + strMinute else strMinute
      str = str.replace 'ss', if strSecond.length == 1 then '0' + strSecond else strSecond

      str = str.replace 'yy', strYear.substr 2
      str = str.replace 'M', strMonth
      str = str.replace 'd', strDay
      str = str.replace 'H', strHour
      str = str.replace 'm', strMinute
      str.replace 's', strSecond

    formatUTC : (value, format) ->
      format ?= _FORMAT_UTC
      @format value, format, true

    parse : (str) ->
      res = _regParseUTC.exec str
      if res
        # UTC String
        return DateTime.UTC parseInt(res[1], 10)
          , parseInt(res[2], 10)
          , parseInt(res[3], 10)
          , parseInt(res[4], 10)
          , parseInt(res[5], 10)
          , parseInt(res[6], 10)
          , parseInt(res[7], 10)

      res = _regParse1.exec str
      if res
        return new DateTime parseInt(res[1], 10)
          , parseInt(res[2], 10)
          , parseInt(res[3], 10)
          , parseInt(res[4], 10)
          , parseInt(res[5], 10)
          , parseInt(res[6], 10)
          , parseInt(res[7], 10)
      
      res = _regParse2.exec str
      if res
        return new DateTime parseInt(res[3], 10)
          , parseInt(res[1], 10)
          , parseInt(res[2], 10)
          , parseInt(res[4], 10)
          , parseInt(res[5], 10)
          , parseInt(res[6], 10)
          , parseInt(res[7], 10)
      
      return null

    convertFromJson : (obj, attrs...) ->
      for attr in attrs
        obj[attr] = j3.DateTime.parse obj[attr]

    now : ->
      new DateTime

    today : ->
      (new DateTime).justDate()

    equals : (dateTime1, dateTime2) ->
      if dateTime1 then return dateTime1.equals dateTime2
      return !dateTime2

    lt : (dateTime1, dateTime2) ->
      t1 = if dateTime1 then dateTime1.getTime() else 0
      t2 = if dateTime2 then dateTime2.getTime() else 0
      t1 < t2

    gt : (dateTime1, dateTime2) ->
      t1 = if dateTime1 then dateTime1.getTime() else 0
      t2 = if dateTime2 then dateTime2.getTime() else 0
      t1 > t2

  DateTime
