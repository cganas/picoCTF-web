React = require 'react'
update = require 'react-addons-update'

Noty = require 'noty'

Api = require './utils/api'

CompetitionNavbar = require "./componets/competition_navbar"

App = React.createClass

  getInitialState: ->
    status: {}

  componentWillMount: ->
    Api.call "GET", "/api/user/status"
    .success (resp) =>
      @setState update @state,
        status: $set: resp.data

  render: ->
    childrenWithProps = React.Children.map @props.children, (child) =>
                          React.cloneElement child, {status: @state.status}
    <div>
      <CompetitionNavbar status={@state.status}/>
      <p>App</p>
      <div id="page">
        {childrenWithProps}
      </div>
    </div>

module.exports = App
