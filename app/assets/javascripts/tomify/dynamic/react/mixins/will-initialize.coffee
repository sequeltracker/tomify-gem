@WillInitializeMixin = {
  getInitialState: ->
    @getInitialSetup?()
    @componentWillInitialize?()

    {}
}
