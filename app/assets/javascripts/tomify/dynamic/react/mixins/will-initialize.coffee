@WillInitializeMixin = {
  getInitialState: ->
    @componentWillInitialize?()

    {}
}
