Component.create "Index.Container",
  componentWillInitialize: ->
    @model = Model.findOrCreate @props.name
    @store = Store.findOrCreate "#{@props.name}.Index"
    @records = @store.findOrCreate "Records", []
    @followStores = { store: @store, records: @records }
    context = @
    @follow @model.on "all", (response) ->
      context.records.set(response.data)
      context.setPage(1)
    @follow @model.on "create", (response) ->
      context.model.all() if response.type == "success"
    @follow @model.on "update", (response) ->
      context.model.all() if response.type == "success"
    @follow @model.on "destroy", (response) ->
      context.model.all() if response.type == "danger"
    if @props.import
      @model.findOrCreate "Import"
      @follow @model.Import.on "create", (response) ->
        context.model.all() if response.type == "success"
  componentDidMount: ->
    @model.all()
  setPage: (page) ->
    @setState(page: 1, currentRecords: @state.records[(page*10 - 10)..page*10])
  new: (e) ->
    e.preventDefault()
    @model.new()
    false
  edit: (id, e) ->
    e.preventDefault()
    @model.edit(id)
    false
  destroy: (id, e) ->
    e.preventDefault()
    @model.destroy(id).then (response) ->
      Store.findOrCreate("Messages").push { type: response.type, text: response.message }
    false
  export: (e) ->
    e.preventDefault()
    window.open("data:text/json;charset=utf8,#{JSON.stringify(@state.records)}", "_blank")
    false
  import: (e) ->
    e.preventDefault()
    @model.Import.new()
    false
  render: ->
    context = @
    <div>
      <div className="row">
        <div className="col-xs-12">
          <div className="panel panel-default">
            <div className="panel-heading">
              <h4>
                {@model.name.pluralize.titleize}
                <a className="btn btn-primary btn-xs" href="#" onClick={@new}>New</a>
                {if @props.import
                  [
                    <a key="export" className="btn btn-primary btn-xs" href="#" onClick={@export}>Export</a>
                    <a key="import" className="btn btn-primary btn-xs" href="#" onClick={@import}>Import</a>
                  ]
                }
              </h4>
              <Pagination page="1" total={@state.records.length} setPage={@setPage} />
            </div>
            <div className="table-responsive">
              <table className="table table-bordered table-hover">
                <thead>
                  <tr>
                    {for field, i in @model.columns
                      <th key={i}>{field.name.titleize}</th>
                    }
                  </tr>
                </thead>
                <tbody>
                  {for record, i in @state.records
                    <tr key={i}>
                      {for field, j in context.model.columns
                        if field.name == "actions"
                          <td key={j}>
                            {[
                              field.view && field.view(record)
                              field.view && field.edit && " | "
                              field.edit && <a key="edit" onClick={@edit.bind(null, record.id)} href="#">Edit</a>
                              field.destroy && " | "
                              field.destroy && <a key="destroy" onClick={@destroy.bind(null, record.id)} href="#" data-confirm="Are you sure you want to delete #{record.name}?">Delete</a>
                            ]}
                          </td>
                        else
                          <td key={j}>{field.value?(record) ? record[field.name]}</td>
                      }
                    </tr>
                  }
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
      <New.Container name={@props.name} />
      <Edit.Container name={@props.name} />
      {<Import.Container name={@props.name} /> if @props.import}
    </div>