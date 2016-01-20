React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'

Tabs = RB.Tabs
Tab = RB.Tab

_ = require 'underscore'

update = require 'react-addons-update'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

ManageProblemsTab = require "../components/manage_problems_tab"
ManageExceptionsTab = require "../components/manage_exceptions_tab"
ManageShellServersTab = require "../components/manage_shell_servers_tab"
ManageServerConfigurationTab = require "../components/manage_server_configuration_tab"

Api = require '../utils/api'

AdminManagementPage = React.createClass
  mixins: [History]

  getInitialState: ->
    problems: []
    submissions: []
    bundles: []
    exceptions: []

  onProblemChange: ->
    Api.call "GET", "/api/admin/problems"
    .done (resp) =>
      @setState update @state,
        problems: $set: resp.data.problems
        bundles: $set: resp.data.bundles

    Api.call "GET", "/api/admin/problems/submissions"
    .done (resp) =>
      @setState update @state,
        submissions: $set: resp.data

   onExceptionModification: ->
     Api.call "GET", "/api/admin/exceptions", {limit: 50}
     .done (resp) =>
      @setState update @state,
        exceptions: $set: resp.data

  componentWillMount: ->
    @onProblemChange()
    @onExceptionModification()

  onTabSelect: (tab) ->
    @history.push "/management/#{tab}"

  render: ->
    <Tabs activeKey={@props.params.tab} onSelect={@onTabSelect}>
      <Tab eventKey='problems' title='Manage Problems'>
        <ManageProblemsTab problems={@state.problems} onProblemChange={@onProblemChange}
            bundles={@state.bundles} submissions={@state.submissions}/>
      </Tab>
      <Tab eventKey='exceptions' title='Exceptions'>
        <ManageExceptionsTab exceptions={@state.exceptions}/>
      </Tab>
      <Tab eventKey='shell-servers' title='Shell Server'>
        <ManageShellServersTab servers={@state.servers}/>
      </Tab>
      <Tab eventKey='configuration' title='Configuration'>
        <ManageServerConfigurationTab/>
      </Tab>
    </Tabs>


module.exports = AdminManagementPage
