@WillInitializeMixin = {
  getInitialState: ->
    @componentWillInitialize?()

    {}
}