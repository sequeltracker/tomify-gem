Component.create "New.Container",
  componentWillInitialize: ->
    @model = Model.find_or_create @props.name
    @store = Store.find_or_create "#{@props.name}.New"
    @record = @store.find_or_create "Record", {}
    @changes = @store.find_or_create "Changes", {}
    @followStores = { store: @store, record: @record, changes: @changes }
    @followModels = (field.model for field in @model.fields when field.model)
    context = @
    @follow @model.on "edit", -> context.store.merge(show: false)
    @follow @model.on "new", ->
      context.changes.set({})
      context.record.set({})
      context.store.merge(show: true)
    @follow @model.on "create", (response) ->
      Store.find_or_create("Messages").push { type: response.type, text: response.message }
      context.store.merge(show: false) if response.type == "success"
  submit: (e) ->
    e.preventDefault()
    if @changes.empty()
      Store.find_or_create("Messages").push { type: "warning", text: "#{@model.name.titleize} was not created" }
    else
      @model.create @changes.get()
    false
  cancel: (e) ->
    e.preventDefault()
    @store.merge(show: false)
    false
  render: ->
    return <div /> unless @state.store.show
    context = @
    <div className="row">
      <div className="col-xs-12">
        <div className="panel panel-default">
          <div className="panel-heading">
            <h4>New {@model.name.titleize}</h4>
            <a className="btn btn-danger pull-right" href="#" onClick={@cancel}><i className="fa fa-close" /></a>
          </div>
          <div className="panel-body">
            <form className="form-horizontal" onSubmit={@submit}>
              {context.field(field) for field in @model.fields}
              <div className="col-sm-offset-2 col-sm-10">
                <input type="submit" name="commit" value="Create #{@model.name.titleize}" className="btn btn-primary" />
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
