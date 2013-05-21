j3.UA = do ->
  o =
    ie : 0
    gecko : 0
    webkit : 0
    opera : 0
    name : ''

    N_IE : 'MSIE'
    N_FIREFOX : 'Firefox'
    N_OPERA : 'Opera'
    N_CHROME : 'Chrome'
    N_SAFARI : 'Safari'
    N_ANDROID : 'Android'

    P_IPOD : 'iPod'
    P_IPAD : 'iPad'
    P_IPHONE : 'iPhone'
    P_ANDROID : 'Android'

  if !this.navigator
    o.name = 'server'
    return o

  ua = this.navigator.userAgent
  if ua.indexOf(o.N_IE) > -1
    o.ie = true
    o.name = o.N_IE
  else if ua.indexOf(o.N_FIREFOX) > -1
    o.gecko = true
    o.name = o.N_FIREFOX
  else if ua.indexOf(o.N_OPERA) > -1
    o.opera = true
    o.name = o.N_OPERA
  else if ua.indexOf('AppleWebKit') > -1
    o.webkit = true
    if ua.indexOf(o.N_ANDROID) > -1
      o.name = o.N_ANDROID
    else if ua.indexOf(o.N_CHROME) > -1
      o.name = o.N_CHROME
    else if ua.indexOf(o.N_SAFARI) > -1
      o.name = o.N_SAFARI

  if ua.indexOf(o.P_IPOD) > -1
    o.platform = o.P_IPOD
  else if ua.indexOf(o.P_IPAD) > -1
    o.platform = o.P_IPAD
  else if ua.indexOf(o.P_IPHONE) > -1
    o.platform = o.P_IPHONE
  else if ua.indexOf(o.P_ANDROID) > -1
    o.platform = o.P_ANDROID
  
  if o.name is o.N_OPERA or o.name is o.N_SAFARI
    nStart = ua.indexOf('Version') + 8
  else
    nStart = ua.indexOf(o.name) + o.name.length + 1
  
  version = parseFloat ua.substring(nStart, nStart+4).match(/\d+\.\d{1}/i)[0]
  
  if o.ie
    o.ie = version
  else if o.gecko
    o.gecko = version
  else if o.opera
    o.opera = version
  else if o.webkit
    o.webkit = version

  o.supportTouch = document.documentElement and document.documentElement.hasOwnProperty and document.documentElement.hasOwnProperty 'ontouchstart'

  o
