React = require 'react'
update = require 'react-addons-update'

Noty = require 'noty'

Api = require './utils/api'
Status = require "./utils/status"

CompetitionNavbar = require "./components/competition_navbar"

App = React.createClass

  getInitialState: ->
    status: Status.getStatus()

  updateStatus: (status) ->
    @setState status: status

  onStatusChange: (callback) ->
    Status.fetch callback

  componentWillMount: ->
    Status.onChange = @updateStatus
    Status.fetch()

  render: ->
    childrenWithProps = React.Children.map @props.children, (child) =>
                          React.cloneElement child,
                            status: @state.status
                            onStatusChange: @onStatusChange
    <div>
      <CompetitionNavbar status={@state.status}/>
      <div id="page">
        {childrenWithProps}
      </div>
    </div>

module.exports = App
