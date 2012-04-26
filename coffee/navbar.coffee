do (j3) ->
  j3.Navbar = j3.cls j3.ContainerView,
    onInit : (options) ->
      @fixedTop = !!options.fixedTop

    getViewData : ->
      id : @id
      css : 'navbar' +
        (if @fixedTop then ' navbar-fixed-top' else '')
