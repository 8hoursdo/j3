(function() {
  var ext, j3, root;

  root = this;

  j3 = root.j3 = function() {
    return j3.$.apply(this, arguments);
  };

  j3.version = '0.0.1';

  j3.has = function(obj, prop) {
    return obj.hasOwnProperty(prop);
  };

  j3.$ = root.jQuery || function(query) {
    if (typeof query === 'string') {
      if ((query.indexOf('#')) === 0) {
        return document.getElementById(query.substr(1));
      } else {
        return null;
      }
    }
    return query;
  };

  ext = j3.ext = function(original, extend) {
    var prop;
    for (prop in extend) {
      original[prop] = extend[prop];
    }
  };

  j3.cls = function(base, members) {
    var ctor, ctorOfBase, ctorOfCls, proto;
    if (arguments.length === 1) {
      members = base;
      base = null;
    }
    if (base) ctorOfBase = base.prototype.ctor;
    ctorOfCls = members.ctor;
    if (ctorOfBase) {
      if (ctorOfCls) {
        members.ctor = function() {
          ctorOfBase.apply(this, arguments);
          return ctorOfCls.apply(this, arguments);
        };
      } else {
        members.ctor = function() {
          return ctorOfBase.apply(this, arguments);
        };
      }
    } else if (!ctorOfCls) {
      member.ctor = function() {};
    }
    ctor = members.ctor;
    proto = ctor.prototype;
    if (base) this.ext(proto, base.prototype);
    this.ext(proto, members);
    if (this.has(members, 'toString')) proto.toString = members.toString;
    ctor.base = function() {
      return base.prototype;
    };
    return ctor;
  };

  j3.UA = (function() {
    var nStart, o, ua, version;
    o = {
      ie: 0,
      gecko: 0,
      webkit: 0,
      opera: 0,
      name: '',
      N_IE: 'MSIE',
      N_FIREFOX: 'Firefox',
      N_OPERA: 'Opera',
      N_CHROME: 'Chrome',
      N_SAFARI: 'Safari'
    };
    ua = navigator.userAgent;
    if (ua.indexOf(o.N_IE) > -1) {
      o.ie = true;
      o.name = o.N_IE;
    } else if (ua.indexOf(o.N_FIREFOX) > -1) {
      o.gecko = true;
      o.name = o.N_FIREFOX;
    } else if (ua.indexOf(o.N_OPERA) > -1) {
      o.opera = true;
      o.name = o.N_OPERA;
    } else if (ua.indexOf(o.N_CHROME) > -1) {
      o.webkit = true;
      o.name = o.N_CHROME;
    } else if (ua.indexOf(o.N_SAFARI) > -1) {
      o.webkit = true;
      o.name = o.N_SAFARI;
    }
    if (o.name === o.N_OPERA || o.name === o.N_SAFARI) {
      nStart = ua.indexOf('Version') + 8;
    } else {
      nStart = ua.indexOf(o.name) + o.name.length + 1;
    }
    version = parseFloat(ua.substring(nStart, nStart + 4).match(/\d+\.\d{1}/i)[0]);
    if (o.ie) {
      o.ie = version;
    } else if (o.gecko) {
      o.gecko = version;
    } else if (o.opera) {
      o.opera = version;
    } else if (o.webkit) {
      o.webkit = version;
    }
    return o;
  })();

  if (j3.UA.ie >= 8 || j3.UA.opera || j3.UA.webkit) {
    j3.StringBuilder = j3.cls({
      ctor: function() {
        this._data = '';
      },
      append: function(text) {
        this._data += text;
        return this;
      },
      clear: function() {
        this._data = '';
        return this;
      },
      toString: function() {
        return this._data;
      }
    });
  } else {
    j3.StringBuilder = j3.cls({
      ctor: function() {
        this._data = [];
      },
      append: function(text) {
        this._data[this._data.length] = text;
        return this;
      },
      clear: function() {
        this._data = [];
        return this;
      },
      toString: function() {
        return this._data.join('');
      }
    });
  }

  j3.DateTime = (function() {
    var DateTime, _DAY, _HOUR, _MINUTE, _SECOND, _monthNames, _regParse1, _regParse2;
    _SECOND = 1000;
    _MINUTE = 60000;
    _HOUR = 3600000;
    _DAY = 86400000;
    _monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    _regParse1 = /^(\d{4})-(\d{1,2})-(\d{1,2})(?: (\d{1,2}):(\d{1,2}):(\d{1,2})(?::(\d{1,3}))?)?$/;
    _regParse2 = /^(\d{1,2})\/(\d{1,2})\/(\d{4})(?: (\d{1,2}):(\d{1,2}):(\d{1,2})(?::(\d{1,3}))?)?$/;
    DateTime = j3.cls({
      ctor: function(year, month, date, hours, minutes, seconds, ms) {
        var argLen;
        argLen = arguments.length;
        if (argLen === 0) {
          this._value = new Date;
        } else if (argLen === 1) {
          this._value = new Date(year);
        } else {
          month = month || 0;
          date = date || 0;
          hours = hours || 0;
          minutes = minutes || 0;
          seconds = seconds || 0;
          ms = ms || 0;
          this._value = new Date(year, month - 1, date, hours, minutes, seconds, ms);
        }
      },
      getYear: function() {
        return this._value.getFullYear();
      },
      getMonth: function() {
        return this._value.getMonth() + 1;
      },
      getDay: function() {
        return this._value.getDate();
      },
      getDayOfWeek: function() {
        return this._value.getDay();
      },
      justDate: function() {
        return new DateTime(this.getYear(), this.getMonth(), this.getDay());
      },
      justTime: function() {
        return new DateTime(this._value.getTime() % _DAY);
      },
      addYear: function(years) {
        return new DateTime(this._value.getFullYear + years, this._value.getMonth() + 1, this._value.getDate(), this._value.getHours(), this._value.getMinutes(), this._value.getSeconds(), this._value.getMilliseconds());
      },
      addMonth: function(months) {
        var month, year;
        month = this._value.getFullYear() * 12 + this._value.getMonth() + 1 + months;
        year = parseInt(month / 12);
        month %= 12;
        return new DateTime(year, month, this._value.getDate(), this._value.getHours(), this._value.getMinutes(), this._value.getSeconds(), this._value.getMilliseconds());
      },
      addDay: function(days) {
        return new DateTime(this._value.getTime() + _DAY * days);
      },
      addHour: function(hours) {
        return new DateTime(this._value.getTime() + _HOUR * hours);
      },
      addMinute: function(minutes) {
        return new DateTime(this._value.getTime() + _MINUTE * minutes);
      },
      toString: function(format) {
        if (format == null) format = 'yyyy-MM-dd HH:mm:ss';
        return DateTime.format(this._value, format);
      },
      getValue: function() {
        return new Date(this._value.getTime());
      },
      equals: function(dateTime) {
        if (!dateTime) return false;
        return this._value.getTime() === dateTime._value.getTime();
      },
      clone: function() {
        return new DateTime(this._value.getTime());
      }
    });
    j3.ext(DateTime, {
      format: function(value, format) {
        var str, strDay, strHour, strMinute, strMonth, strSecond, strYear;
        if (value instanceof DateTime) value = value.getValue();
        if (typeof value === 'number') {
          value = new Date(value);
        } else if (!value instanceof Date) {
          return '';
        }
        strYear = value.getFullYear().toString();
        strMonth = (value.getMonth() + 1).toString();
        strDay = value.getDate().toString();
        strHour = value.getHours().toString();
        strMinute = value.getMinutes().toString();
        strSecond = value.getSeconds().toString();
        str = format.replace('yyyy', strYear);
        str = str.replace('MMM', _monthNames[value.getMonth()]);
        str = str.replace('MM', strMonth.length === 1 ? '0' + strMonth : strMonth);
        str = str.replace('dd', strDay.length === 1 ? '0' + strDay : strDay);
        str = str.replace('HH', strHour.length === 1 ? '0' + strHour : strHour);
        str = str.replace('mm', strMinute.length === 1 ? '0' + strMinute : strMinute);
        str = str.replace('ss', strSecond.length === 1 ? '0' + strSecond : strSecond);
        str = str.replace('yy', strYear.substr(2));
        str = str.replace('M', strMonth);
        str = str.replace('d', strDay);
        str = str.replace('H', strHour);
        str = str.replace('m', strMinute);
        return str.replace('s', strSecond);
      },
      parse: function(str) {
        var res;
        res = _regParse1.exec(str);
        if (res) {
          return new DateTime(parseInt(res[1], 10), parseInt(res[2], 10), parseInt(res[3], 10), parseInt(res[4], 10), parseInt(res[5], 10), parseInt(res[6], 10), parseInt(res[7], 10));
        }
        res = _regParse2.exec(str);
        if (res) {
          return new DateTime(parseInt(res[3], 10), parseInt(res[1], 10), parseInt(res[2], 10), parseInt(res[4], 10), parseInt(res[5], 10), parseInt(res[6], 10), parseInt(res[7], 10));
        }
        return null;
      },
      now: function() {
        return new DateTime;
      },
      today: function() {
        return (new DateTime).justDate();
      },
      equals: function(dateTime1, dateTime2) {
        if (dateTime1) return dateTime1.equals(dateTime2);
        return !dateTime2;
      }
    });
    return DateTime;
  })();

  j3.String = (function() {
    var J3String, _regFormat, _regTime;
    _regTime = /^\s+|\s+$/g;
    _regFormat = /{(\d+)?}/g;
    J3String = {
      format: function(text) {
        var args;
        args = arguments;
        if (args.length === 0) return '';
        if (args.length === 1) return text;
        return text.replace(_regFormat, function($0, $1) {
          return args[parseInt($1) + 1];
        });
      },
      include: function(s, s1, s2) {
        if (s2 && s2.length) {
          return (s2 + s + s2).indexOf(s2 + s1 + s2) > -1;
        } else {
          return s.indexOf(s1) > -1;
        }
      },
      isNullOrEmpty: function(s) {
        return typeof s === 'undefined' || s === null || s === '';
      },
      hyphenlize: function(s) {
        var c, converted, i, len;
        converted = '';
        i = -1;
        len = s.length;
        while (++i < len) {
          c = s.charAt(i);
          if (c === c.toUpperCase()) {
            converted += '-' + c.toLowerCase();
          } else {
            converted += c;
          }
        }
        return converted;
      }
    };
    if (String.prototype.trim) {
      J3String.trim = function(s) {
        if (this.isNullOrEmpty(s)) return '';
        return s.trim();
      };
    } else {
      J3String.trim = function(s) {
        if (this.isNullOrEmpty(s)) return '';
        return s.replace(_regTime, '');
      };
      String.prototype.trim = function() {
        return s.replace(_regTime, '');
      };
    }
    return J3String;
  })();

  j3.Dom = (function() {
    var Dom, UA, __clientHeight_gecko, __clientHeight_ie, __clientHeight_opera, __clientWidth_gecko, __clientWidth_ie, __clientWidth_opera, __getStyle_ie, __getStyle_other, __height_ie, __height_other, __opacity_ie, __opacity_other, __position, __position_op_webkit, __width_ie, __width_other, _tempDiv;
    UA = j3.UA;
    _tempDiv = document.createElement('div');
    Dom = {
      append: function(target, el) {
        var els;
        if (!target) return;
        if (typeof el === 'string') {
          _tempDiv.innerHTML = el;
          if (_tempDiv.childNodes.length > 1) {
            els = [];
            while (_tempDiv.firstChild) {
              els[els.length] = target.appendChild(_tempDiv.firstChild);
            }
            return els;
          }
          return target.appendChild(_tempDiv.firstChild);
        }
        return target.appendChild(el);
      },
      indexOf: function(el) {
        var index, node, p, _i, _len, _ref;
        p = el.parentNode;
        if (!p) return -1;
        index = 0;
        _ref = p.childNodes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          if (node.nodeType === 1) {
            if (node === el) return index;
            ++index;
          }
        }
        return -1;
      },
      byIndex: function(el, index) {
        var node, pi, _i, _len, _ref;
        if (!el) return null;
        pi = 0;
        _ref = el.childNodes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          if (node.nodeType === 1) {
            if (pi === index) return node;
            ++pi;
          }
        }
        return null;
      },
      next: function(el) {
        if (!el) return null;
        el = el.nextSibling;
        while (el) {
          if (el.nodeType === 1) return el;
          el = el.nextSibling;
        }
        return null;
      },
      previous: function(el) {
        if (!el) return null;
        el = el.previousSibling;
        while (el) {
          if (el.nodeType === 1) return el;
          el = el.previousSibling;
        }
        return null;
      },
      offsetWidth: function(el, width) {
        var delta;
        if (arguments.length === 1) return el.offsetWidth;
        if (width === -1) {
          el.style.width = '';
        } else {
          delta = el.offsetWidth - this.width(el);
          el.style.width = (width - delta) + 'px';
        }
      },
      offsetHeight: function(el, height) {
        var delta;
        if (arguments.length === 1) return el.offsetHeight;
        if (height === -1) {
          el.style.height = '';
        } else {
          delta = el.offsetHeight - this.height(el);
          el.style.height = (height - delta) + 'px';
        }
      },
      place: function(el, left, top, clientAbs) {
        var pos, s;
        s = el.style;
        s.left = s.top = '0';
        pos = this.position(el, clientAbs);
        if (typeof left !== 'undefined') s.left = (left - pos.left) + 'px';
        if (typeof top !== 'undefined') s.top = (top - pos.top) + 'px';
      }
    };
    __width_ie = function(el) {
      var borderLeft, borderRight, cs, paddingLeft, paddingRight;
      cs = el.currentStyle;
      borderLeft = parseInt(cs.borderLeftWidth) || 0;
      borderRight = parseInt(cs.borderRightWidth) || 0;
      paddingLeft = parseInt(cs.paddingLeft) || 0;
      paddingRight = parseInt(cs.paddingRight) || 0;
      return el.offsetWidth - borderLeft - borderRight - paddingLeft - paddingRight;
    };
    __height_ie = function(el) {
      var borderBottom, borderTop, cs, paddingBottom, paddingTop;
      cs = el.currentStyle;
      borderTop = parseInt(cs.borderTopWidth) || 0;
      borderBottom = parseInt(cs.borderBottomWidth) || 0;
      paddingTop = parseInt(cs.paddingTop) || 0;
      paddingBottom = parseInt(cs.paddingBottom) || 0;
      return el.offsetHeight - borderTop - borderBottom - paddingTop - paddingBottom;
    };
    __width_other = function(el) {
      return parseInt(document.defaultView.getComputedStyle(el, null).getPropertyValue('width'));
    };
    __height_other = function(el) {
      return parseInt(document.defaultView.getComputedStyle(el, null).getPropertyValue('height'));
    };
    __position = function(el, clientAbs) {
      var box, de, l, t;
      if (el.parentNode === null || this.getStyle(el, 'display') === 'none') {
        return null;
      }
      box = el.getBoundingClientRect();
      l = box.left;
      t = box.top;
      if (UA.ie && UA.version === 7 && window === top) {
        l -= 2;
        t -= 2;
      }
      if (!clientAbs) {
        de = document.documentElement;
        l += de.scrollLeft;
        t += de.scrollTop;
      }
      return {
        left: l,
        top: t
      };
    };
    __position_op_webkit = function(el, clientAbs) {
      var de, l, t;
      if (el.parentNode === null || this.getStyle(el, 'display') === 'none') {
        return null;
      }
      l = 0;
      t = 0;
      while (el) {
        l += el.offsetLeft || 0;
        t += el.offsetTop || 0;
        if (el.offsetParent === document.body && this.getStyle(el, 'position') === 'absolute') {
          break;
        }
        el = el.offsetParent;
      }
      if (clientAbs) {
        de = document.documentElement;
        l -= de.scrollLeft;
        t -= de.scrollTop;
      }
      return {
        left: l,
        top: t
      };
    };
    __opacity_ie = function(el, value) {
      var filter;
      if (arguments.length === 1) {
        if (el.filters.length === 0) return 1;
        filter = el.filters.item('alpha');
        if (!filter) filter = el.filters.item('DXImageTransform.Microsoft.Alpha');
        if (filter) {
          return filter.opacity / 100;
        } else {
          return 1;
        }
      } else {
        el.style.filter = "alpha(opacity=" + (value * 100) + ")";
        if (!el.currentStyle.hasLayout) el.style.zoom = 1;
      }
    };
    __opacity_other = function(el, value) {
      if (arguments.length === 1) {
        return document.defaultView.getComputedStyle(el, '').getPropertyValue('opacity');
      } else {
        el.style.opacity = value;
        el.style['-moz-opacity'] = value;
        return el.style['-khtml-opacity'] = value;
      }
    };
    __getStyle_ie = function(el, styleName) {
      if (styleName === 'opacity') {
        return this.opacity(el);
      } else {
        return el.currentStyle[styleName];
      }
    };
    __getStyle_other = function(el, styleName) {
      var value;
      if (styleName === 'opacity') return this.opacity(el);
      value = el.style[styleName];
      if (value) return value;
      return document.defaultView.getComputedStyle(el, '').getPropertyValue(j3.String.hyphenlize(styleName));
    };
    __clientWidth_ie = function(wnd) {
      if (wnd == null) wnd = window;
      return wnd.document.documentElement.clientWidth;
    };
    __clientHeight_ie = function(wnd) {
      if (wnd == null) wnd = window;
      return wnd.document.documentElement.clientHeight;
    };
    __clientWidth_opera = function(wnd) {
      if (wnd == null) wnd = window;
      return wnd.document.body.clientWidth;
    };
    __clientWidth_gecko = function(wnd) {
      if (wnd == null) wnd = window;
      return wnd.innerWidth;
    };
    __clientHeight_gecko = __clientHeight_opera = function(wnd) {
      if (wnd == null) wnd = window;
      return wnd.innerHeight;
    };
    if (UA.ie) {
      j3.ext(Dom, {
        clientWidth: __clientWidth_ie,
        clientHeight: __clientHeight_ie,
        width: __width_ie,
        height: __height_ie,
        position: __position,
        getStyle: __getStyle_ie,
        opacity: __opacity_ie,
        position: __position
      });
    } else {
      if (UA.gecko) {
        j3.ext(Dom, {
          clientWidth: __clientWidth_gecko,
          clientHeight: __clientHeight_gecko,
          position: __position
        });
      } else {
        j3.ext(Dom, {
          clientWidth: __clientWidth_opera,
          clientHeight: __clientHeight_opera,
          position: __position_op_webkit
        });
      }
      j3.ext(Dom, {
        width: __width_other,
        height: __height_other,
        getStyle: __getStyle_other,
        opacity: __opacity_other
      });
    }
    if (UA.ie && UA.version >= 8 && Dom.position(document.documentElement).left === 2) {
      UA.version = 7;
    }
    return Dom;
  })();

  j3.List = j3.cls({
    ctor: function() {
      this._count = 0;
    },
    firstNode: function() {
      return this._firstNode;
    },
    first: function() {
      return this._firstNode.value;
    },
    lastNode: function() {
      return this._lastNode;
    },
    last: function() {
      return this._lastNode.value;
    },
    count: function() {
      return this._count;
    },
    insertNode: function(node, target) {
      node.list = this;
      if (!this._first) {
        node.prev = node.next = null;
        this._first = this._last = node;
      } else if (!target) {
        node.next = null;
        node.prev = this._last;
        this._last.next = node;
        this._last = node;
      } else {
        node.next = target;
        node.prev = target.prev;
        target.prev = node;
        if (!node.prev) {
          this._first = node;
        } else {
          node.prev.next = node;
        }
      }
      this._count++;
      return this;
    },
    insert: function(value, target) {
      return this.insertNode({
        value: value
      }, target);
    },
    removeNode: function(node) {
      if (node) {
        if (node === this._first) {
          this._first = node.next;
        } else {
          node.prev.next = node.next;
        }
        if (node === this._last) {
          this._last = node.prev;
        } else {
          node.next.prev = node.prev;
        }
        this._count--;
        delete node.value;
        delete node.prev;
        delete node.next;
        delete node.list;
      }
      return this;
    },
    remove: function(value) {
      return this.removeNode(this.findNode(value));
    },
    clear: function() {
      var next, node;
      node = this._first;
      while (node) {
        next = node.next;
        delete node.value;
        delete node.prev;
        delete node.next;
        delete node.list;
        node = next;
      }
      this._first = this._last = null;
      return this._count = 0;
    },
    findNode: function(value) {
      var node;
      node = this._first;
      if (value && value.equals) {
        while (node) {
          if (value.equals(node.value)) return node;
          node = node.next;
        }
      } else {
        while (node) {
          if (value === node.value) return node;
          node = node.next;
        }
      }
      return null;
    },
    contains: function(value) {
      return null !== this.findNode(value);
    },
    getNodeAt: function(index) {
      var node;
      if (index < 0 || index > this._count) return null;
      node = this._first;
      while (index--) {
        node = node.next;
      }
      return node;
    },
    getAt: function(index) {
      var node;
      node = this.getNodeAt(index);
      if (node) return node.value;
    },
    toString: function() {
      var node, sb;
      sb = new j3.StringBuilder;
      sb.append('[');
      node = this._first;
      if (node) {
        sb.append(node.value.toString());
        while (node) {
          sb.append(',');
          sb.append(node.value.toString());
          node = node.next;
        }
      }
      sb.append(']');
      return sb.toString();
    },
    forEach: function(callback, context, arg) {
      var node;
      node = this._first;
      while (node) {
        callback.call(context, node.value, arg);
        node = node.next;
      }
    },
    tryUntil: function(callback, context, arg) {
      var node;
      node = this._first;
      while (node) {
        if (callback.call(context, node.value, arg)) return node.value;
        node = node.next;
      }
    },
    doWhile: function(callback, context, arg) {
      var node;
      node = this._first;
      while (node) {
        if (!callback.call(context, node.value, arg)) return node.value;
        node = node.next;
      }
    }
  });

  j3.EventManager = {
    on: function(name, handler, context) {
      var handlerList, handlerName, handlers;
      if (!this._eventHandlers) this._eventHandlers = {};
      if (arguments.length === 1) {
        handlers = name;
        for (handlerName in handlers) {
          handlerList = this._eventHandlers[handlerName];
          if (!handlerList) {
            this._eventHandlers[handlerName] = handlerList = new j3.List;
          }
          handlerList.insert({
            handler: handlers[handlerName],
            context: null
          });
        }
      } else {
        handlerList = this._eventHandlers[name];
        if (!handlerList) this._eventHandlers[name] = handlerList = new j3.List;
        handlerList.insert({
          handler: handler,
          context: context
        });
      }
      return this;
    },
    off: function(name, handler, context) {
      var handlerList;
      if (!this._eventHandlers) return this;
      handlerList = this._eventHandlers[name];
      if (!handlerList) return this;
      handlerList.removeNode(handlerList.findNode({
        handler: handler,
        context: context,
        equals: function(obj) {
          return this.handler === obj.handler && this.context === obj.context;
        }
      }));
      return this;
    },
    fire: function(name, sender, args) {
      var handlerList;
      if (!this._eventHandlers) return this;
      handlerList = this._eventHandlers[name];
      if (!handlerList) return this;
      handlerList.forEach(function(obj) {
        return obj.handler.call(obj.context, sender, args);
      });
      return this;
    }
  };

  j3.View = (function() {
    var view, _creatingStack, _idSeed, _viewCreated;
    _idSeed = 0;
    _creatingStack = 0;
    _viewCreated = function() {
      var node, options;
      this.el = $('#' + this.id);
      if (this.children) {
        node = this.children.first();
        while (node) {
          _viewCreated.call(node.value);
          node = node.next;
        }
      }
      options = this._options;
      this.onCreated && this.onCreated(options);
      return options.on && this.on(options.on);
    };
    view = j3.cls({
      ctor: function(options) {
        var buffer;
        _creatingStack++;
        if (options == null) options = {};
        this._options = options;
        this.id = options.id || ('v_' + (++_idSeed));
        this.parent = options.parent;
        this.ctnr = $(options.ctnr);
        this.onInit && this.onInit(options);
        this.innerHTML = options.innerHTML;
        this.createChildren && this.createChildren(options);
        _creatingStack--;
        if (!this.parent || _creatingStack === 0) {
          buffer = new j3.StringBuilder;
          this.render(buffer);
          this.ctnr.append(buffer.toString());
          _viewCreated.call(this);
        }
        return delete this._options;
      },
      render: function(buffer) {
        this.onRender(buffer, this.getViewData());
      },
      onRender: function(buffer, data) {
        buffer.append(this.template(data));
      },
      getViewData: function() {
        return {
          id: this.id,
          css: this.css
        };
      }
    });
    j3.ext(view.prototype, j3.EventManager);
    return view;
  })();

  j3.ContainerView = j3.cls(j3.View, {
    onRender: function(buffer, data) {
      this.renderBegin(buffer, data);
      if (this.innerHTML) {
        buffer.append(this.innerHTML);
      } else if (this.children) {
        this.renderChildren(buffer);
      }
      return this.renderEnd(buffer, data);
    },
    renderBegin: function(buffer, data) {
      buffer.append(this.templateBegin(data));
    },
    renderEnd: function(buffer, data) {
      buffer.append(this.templateEnd(data));
    },
    renderChildren: function(buffer) {
      var node;
      node = this.children.first();
      while (node) {
        node.value.render(buffer);
        node = node.next;
      }
    }
  });

  j3.Button = j3.cls(j3.View, {
    css: 'btn',
    template: _.template('<button type="<%=primary ? "submit" : "button"%>" id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><%=text%></button>'),
    onInit: function(options) {
      this._text = options.text || '';
      this._primary = !!options.primary;
      return this._disabled = !!options.disabled;
    },
    getViewData: function() {
      return {
        id: this.id,
        css: this.css + (this._primary ? ' ' + this.css + '-primary' : '') + (this._disabled ? ' disabled' : ''),
        text: this._text,
        primary: this._primary,
        disabled: this._disabled
      };
    },
    onCreated: function() {
      var _this = this;
      return this.el.click(function() {
        return _this.fire('click', _this);
      });
    },
    getText: function() {
      return this._text;
    },
    setText: function(text) {
      this._text = text || '';
      return this.el.innerHTML = this._text;
    },
    getDisabled: function() {
      return this._disabled;
    },
    setDisabled: function(value) {
      this._disabled = !!value;
      this.el.attr('disabled', this._disabled);
      return this.el.toggleClass('disabled');
    }
  });

  j3.Textbox = j3.cls(j3.View, {
    css: 'input',
    templateInput: _.template('<input type="<%=type%>" id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readonly){%> readonly="readonly"<%}%> value="<%-text%>" />'),
    templateTextarea: _.template('<textarea id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%><%if(readonly){%> readonly="readonly"<%}%>><%-text%></textarea>'),
    onInit: function(options) {
      this._text = options.text || '';
      this._primary = !!options.primary;
      this._disabled = !!options.disabled;
      this._readonly = !!options.readonly;
      this._type = options.type || 'text';
      return this._multiline = this._type === 'text' && !!options.multiline;
    },
    getViewData: function() {
      return {
        id: this.id,
        css: this.css + (this._disabled ? ' disabled' : ''),
        text: this._text,
        disabled: this._disabled,
        readonly: this._readonly,
        type: this._type
      };
    },
    onRender: function(buffer) {
      var template;
      if (this._multiline) {
        template = this.templateTextarea;
      } else {
        template = this.templateInput;
      }
      buffer.append(template(this.getViewData()));
    },
    onCreated: function() {
      var _this = this;
      this.el.focus(function() {
        return _this.fire('focus', _this);
      });
      this.el.blur(function() {
        return _this.fire('blur', _this);
      });
      return this.el.keyup(function() {
        var text;
        text = _this.el.attr('value');
        if (_this.getText !== text) {
          _this._text = text;
          return _this.fire('change', _this);
        }
      });
    },
    getText: function() {
      return this._text;
    },
    setText: function(text) {
      text = text || '';
      if (this._text === text) return;
      this._text = text;
      this.el.attr('value', this._text);
      return this.fire('change', this);
    },
    getDisabled: function() {
      return this._disabled;
    },
    setDisabled: function(value) {
      this._disabled = !!value;
      this.el.attr('disabled', this._disabled);
      return this.el.toggleClass('disabled');
    },
    getReadonly: function() {
      return this._readonly;
    },
    setDisabled: function(value) {
      this._readonly = !!value;
      return this.el.attr('readonly', this._readonly);
    }
  });

  j3.Calendar = (function() {
    var Calendar, __getFirstDateOfMonthView, __monthViewClick;
    __getFirstDateOfMonthView = function(year, month, firstDayOfWeek) {
      var startDate;
      startDate = new j3.DateTime(year, month, 1);
      startDate = startDate.addDay(0 - startDate.getDayOfWeek() + firstDayOfWeek);
      if (startDate.getMonth() === month && startDate.getDay() > 1) {
        startDate = startDate.addDay(-7);
      }
      return startDate;
    };
    __monthViewClick = function(evt) {
      var calendar, cellIndex, clickedCell, clickedDate, rowIndex;
      calendar = evt.data;
      clickedCell = this.parentNode;
      rowIndex = clickedCell.parentNode.rowIndex;
      cellIndex = clickedCell.cellIndex;
      clickedDate = calendar._firstDateOfMonthView.addDay((rowIndex - 1) * 7 + cellIndex);
      return calendar.setCurrentDate(clickedDate);
    };
    Calendar = j3.cls(j3.View, {
      onInit: function(options) {
        var today;
        if (options.firstDayOfWeek == null) options.firstDayOfWeek = 1;
        this._firstDayOfWeek = options.firstDayOfWeek % 7;
        this._date = options.date;
        today = j3.DateTime.today();
        if (options.year) {
          this._year = options.year;
        } else if (this._date) {
          this._year = this._date.getYear();
        } else {
          this._year = today.getYear();
        }
        if (options.month) {
          this._month = options.month;
        } else if (this._date) {
          this._month = this._date.getMonth();
        } else {
          this._month = today.getMonth();
        }
      },
      onCreated: function() {
        var _this = this;
        this.el.find('.cld-month-view').delegate('a', 'click', this, __monthViewClick);
        this.el.find('.cld-prev-month').on('click', function() {
          _this._month--;
          if (_this._month === 0) {
            _this._year--;
            _this._month = 12;
          }
          _this.refreshMonthView();
          return _this.el.find('.cld-cur-year-month').html(_this._year + ' - ' + _this._month);
        });
        this.el.find('.cld-next-month').on('click', function() {
          _this._month++;
          if (_this._month === 13) {
            _this._year++;
            _this._month = 1;
          }
          _this.refreshMonthView();
          return _this.el.find('.cld-cur-year-month').html(_this._year + ' - ' + _this._month);
        });
        return this.el.find('.cld-cur-year-month').html(this._year + ' - ' + this._month);
      },
      render: function(buffer) {
        buffer.append('<div id="' + this.id + '" class="cld">');
        buffer.append('<div class="cld-top">');
        buffer.append('<a class="cld-next-month"></a>');
        buffer.append('<a class="cld-prev-month"></a>');
        buffer.append('<div class="cld-cur-year-month"></div>');
        buffer.append('</div>');
        buffer.append('<div class="cld-month-view">');
        this.renderMonthView(buffer);
        buffer.append('</div>');
        buffer.append('</div>');
      },
      renderMonthView: function(buffer) {
        var dayOfWeek, i, isCurDate, j, renderingDate, today;
        buffer.append('<table><tr>');
        for (i = 0; i < 7; i++) {
          dayOfWeek = (this._firstDayOfWeek + i) % 7;
          buffer.append('<th class="cld-weekday-"' + dayOfWeek + '>' + j3.Lang.dayNameAbb[dayOfWeek] + '</th>');
        }
        buffer.append('</tr>');
        today = j3.DateTime.today();
        this._firstDateOfMonthView = __getFirstDateOfMonthView(this._year, this._month, this._firstDayOfWeek);
        this._lastDateOfMonthView = this._firstDateOfMonthView.addDay(42);
        renderingDate = this._firstDateOfMonthView;
        for (i = 0; i < 6; i++) {
          buffer.append('<tr>');
          for (j = 0; j < 7; j++) {
            isCurDate = renderingDate.equals(this._date);
            buffer.append('<td class="');
            buffer.append('cld-weekday-' + renderingDate.getDayOfWeek());
            if (renderingDate.equals(today)) buffer.append(' cld-today');
            if (isCurDate) buffer.append(' active');
            buffer.append('"><a>' + renderingDate.getDay() + '</a></td>');
            renderingDate = renderingDate.addDay(1);
          }
          buffer.append('</tr>');
        }
        buffer.append('</table>');
      },
      refreshMonthView: function() {
        var buffer;
        buffer = new j3.StringBuilder;
        this.renderMonthView(buffer);
        return this.el.find('.cld-month-view').html(buffer.toString());
      },
      setCurrentDate: function(date) {
        var oldDate;
        if (j3.DateTime.equals(this._date, date)) return;
        oldDate = this._date;
        this._date = date;
        this.refreshMonthView();
        return this.fire('change', this, {
          oldDate: oldDate,
          curDate: date
        });
      }
    });
    return Calendar;
  })();

  j3.Selector = j3.cls(j3.View, {
    template: _.template('<div id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><div class="sel-lbl"></div><input type="text" class="sel-txt" /><a class="sel-trigger"><i class="<%=cssTrigger%>"></i></a></div>'),
    onInit: function(options) {
      return this._disabled = !!options.disabled;
    },
    onCreated: function() {
      this._elLabel = this.el.find('.sel-lbl');
      return this._elText = this.el.find('.sel-txt');
    },
    getViewData: function() {
      return {
        id: this.id,
        css: 'sel' + (this._disabled ? ' disabled' : ''),
        cssTrigger: this.cssTrigger,
        disabled: this._disabled
      };
    },
    getDisabled: function() {
      return this._disabled;
    },
    setDisabled: function(value) {
      this._disabled = !!value;
      return this.el.toggleClass('disabled');
    },
    setLabel: function(html) {
      return this._elLabel.html(html);
    },
    setText: function(text) {
      return this._elText.attr('value', text);
    }
  });

  j3.Dropdown = j3.cls(j3.Selector, {
    cssTrigger: 'icon-drp-down',
    onCreated: function() {
      var _this = this;
      j3.Dropdown.base().onCreated.call(this);
      this.el.find('.sel-trigger').on('click', function() {
        return _this.toggle();
      });
    },
    isDropdown: function() {
      return this._isDropdown;
    },
    toggle: function() {
      if (this._isDropdown) {
        this.close();
      } else {
        this.dropdown();
      }
    },
    dropdown: function() {
      var elBox, firstTime, pos;
      firstTime = !this._elDropdownBox;
      if (firstTime) {
        elBox = document.createElement('div');
        elBox.className = 'drp-box';
        this._elDropdownBox = $(elBox);
        this.el.append(elBox);
        this.onCreateDropdownBox(this._elDropdownBox);
      }
      this.fire('beforeDropdown', this, {
        firstTime: firstTime
      });
      this.el.addClass('sel-active');
      this._elDropdownBox.show();
      pos = j3.Dom.position(this.el[0]);
      pos.top += j3.Dom.offsetHeight(this.el[0]);
      j3.Dom.place(this._elDropdownBox[0], pos.left, pos.top + 2);
      this.fire('dropdown', this, {
        firstTime: firstTime
      });
      this._isDropdown = true;
    },
    close: function() {
      this.el.removeClass('sel-active');
      this._elDropdownBox && this._elDropdownBox.hide();
      this.fire('close', this);
      this._isDropdown = false;
    }
  });

  j3.DropdownList = j3.cls(j3.Dropdown, {
    onInit: function(options) {
      var eachItem, items, list, _i, _len;
      j3.DropdownList.base().onInit.call(this, options);
      items = options.items;
      list = new j3.List;
      if (items) {
        if (_.isArray(items)) {
          for (_i = 0, _len = items.length; _i < _len; _i++) {
            eachItem = items[_i];
            if (eachItem.value == null) eachItem.value = eachItem.text;
            list.insert(eachItem);
          }
        } else if (items instanceof j3.List) {
          items.forEach(function(item) {
            if (item.value == null) item.value = item.text;
            return list.insert(item);
          });
          this._items = options.items;
        }
      }
      this._items = list;
      return this._selectedValue = options.value;
    },
    onCreated: function() {
      j3.DropdownList.base().onCreated.call(this);
      return this.setSelectedValue(this._selectedValue);
    },
    onCreateDropdownBox: function(elBox) {
      var buffer,
        _this = this;
      buffer = new j3.StringBuilder;
      buffer.append('<ul class="drp-list">');
      this._items && this._items.forEach(function(item) {
        buffer.append('<li');
        if (item.value === _this._selectedValue) buffer.append(' class="active"');
        return buffer.append('><a>' + item.text + '</a></li>');
      });
      buffer.append('</ul>');
      elBox.append(buffer.toString());
      this._elDrpList = j3.Dom.byIndex(elBox[0], 0);
      return elBox.delegate('li', 'click', this, function(evt) {
        evt.data.setSelectedIndex(j3.Dom.indexOf(this));
        return evt.data.close();
      });
    },
    getItems: function() {
      return this._items;
    },
    setItems: function(items) {
      return this._items = items;
    },
    setSelectedValue: function(value) {
      var index,
        _this = this;
      index = 0;
      this._items.tryUntil(function(item) {
        if (item.value === value) {
          return true;
        } else {
          ++index;
          return false;
        }
      });
      return this.setSelectedIndex(index);
    },
    setSelectedIndex: function(index) {
      var item, oldIndex, oldSelectedIndex, oldSelectedValue;
      if (index < 0 && index >= this._items.count()) return;
      oldIndex = this._selectedIndex;
      if (oldIndex === index) return;
      if (this._elDrpList) {
        $(j3.Dom.byIndex(this._elDrpList, oldIndex)).removeClass('active');
        $(j3.Dom.byIndex(this._elDrpList, index)).addClass('active');
      }
      item = this._items.getAt(index);
      this.setLabel(item.text);
      this.setText(item.text);
      oldSelectedValue = this._selectedValue;
      oldSelectedIndex = this._selectedIndex;
      this._selectedIndex = index;
      this._selectedValue = item.value;
      return this.fire('change', this, {
        oldIndex: oldSelectedIndex,
        oldValue: oldSelectedValue,
        curIndex: this._selectedIndex,
        curValue: this._selectedValue
      });
    }
  });

  j3.DateSelector = j3.cls(j3.Dropdown, {
    cssTrigger: 'icon-calendar',
    onInit: function(options) {
      j3.DateSelector.base().onInit.call(this, options);
      return this._date = options.date;
    },
    onCreated: function() {
      j3.DateSelector.base().onCreated.call(this);
      if (this._date) return this.setLabel(this._date.toString('yyyy-MM-dd'));
    },
    onCreateDropdownBox: function(elBox) {
      var _this = this;
      this._calendar = new j3.Calendar({
        ctnr: elBox[0],
        date: this._date
      });
      return this._calendar.on('change', function(sender, args) {
        _this.setLabel(args.curDate.toString('yyyy-MM-dd'));
        return _this.close();
      });
    }
  });

}).call(this);
