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

  (function() {
    var _tempDiv;
    _tempDiv = document.createElement('div');
    return j3.append = function(target, el) {
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
    };
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
    getNodeByIndex: function(index) {
      var node;
      if (index < 0 || index > this._count) return null;
      node = this._first;
      while (index--) {
        node = node.next;
      }
      return node;
    },
    getByIndex: function(index) {
      var node;
      node = this.getNodeByIndex(index);
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

  j3.Selector = j3.cls(j3.View, {
    css: 'sel',
    template: _.template('<div id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><input type="text" class="<%=css%>-input" /><button type="button" class="<%=css%>-trigger"><i class="<%=cssTrigger%>"></i></button></div>'),
    onInit: function(options) {
      return this._disabled = !!options.disabled;
    },
    getViewData: function() {
      return {
        id: this.id,
        css: this.css + (this._disabled ? ' disabled' : ''),
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
    }
  });

  j3.Dropdown = j3.cls(j3.Selector, {
    cssTrigger: 'icon-drp-down',
    onCreated: function() {
      var _this = this;
      this.el.find('button').on('click', function() {
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
      var elBox, firstTime;
      firstTime = !this._elDropdownBox;
      this.fire('beforeDropdown', this, {
        firstTime: firstTime
      });
      if (firstTime) {
        elBox = document.createElement('div');
        elBox.className = 'drp-box';
        this._elDropdownBox = $(elBox);
        this.el.append(elBox);
        this.onCreateDropdownBox(this._elDropdownBox);
      }
      this._elDropdownBox.show();
      this.fire('dropdown', this, {
        firstTime: firstTime
      });
      this._isDropdown = true;
    },
    close: function() {
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
      return this._value = options.value;
    },
    onCreateDropdownBox: function(elBox) {
      var buffer,
        _this = this;
      buffer = new j3.StringBuilder;
      buffer.append('<ul class="drp-list">');
      this._items && this._items.forEach(function(item) {
        buffer.append('<li');
        if (item.value === _this._value) buffer.append(' class="active"');
        return buffer.append('><a>' + item.text + '</a></li>');
      });
      buffer.append('</ul>');
      elBox.append(buffer.toString());
      return elBox.on('click a', function(evt) {
        return alert(evt.target);
      });
    },
    getItems: function() {
      return this._items;
    },
    setItems: function(items) {
      return this._items = items;
    }
  });

}).call(this);
