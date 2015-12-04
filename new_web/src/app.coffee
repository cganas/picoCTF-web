React = require 'react'
update = require 'react-addons-update'

Noty = require 'noty'

Api = require './utils/api'

App = React.createClass

  getInitialState: ->
    status: {}

  componentWillMount: ->
    Api.call "GET", "/api/user/status"
    .success ((resp) ->
      Api.notify resp
      @setState update @state,
        status: $set: resp.data
    ).bind this

  render: ->
    childrenWithProps = React.Children.map @props.children, ((child) ->
                          React.cloneElement child, {status: @state.status}).bind this
    <div>
      <p>App</p>
      <div id="page">
        {childrenWithProps}
      </div>
    </div>

module.exports = App
