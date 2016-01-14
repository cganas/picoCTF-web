React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'

Grid = RB.Grid
Col = RB.Col

Nav = RB.Nav
NavItem = RB.NavItem

_ = require 'underscore'

update = require 'react-addons-update'

Api = require '../utils/api'

OrganizationManagementPage = React.createClass
  mixins: [History]

  getInitialState: ->
    groups: []
    groupSettings: {}
    activeTab: @props.params.organization

  onGroupsChange: ->
    Api.call "GET", "/api/group/list"
    .done (resp) =>
      if resp.status == "success"
        @setState update @state, $set: groups: resp.data
      else
        Api.notify resp

  componentWillMount: ->
    @onGroupsChange()

  onSelect: (tab) ->
    @history.push "/organization/#{tab}"
    @setState update @state, $set: activeTab: tab

  render: ->
    organizationView = React.cloneElement @props.children,
      groups: @state.groups
      key: @props.params.organization
      gid: @props.params.organization
      userStatus: @props.status
      onGroupChange: @onGroupChange

    <Grid>
      <Col xs={2}>
        <Nav bsStyle="pills" stacked activeKey={@state.activeTab} onSelect={@onSelect}>
          {@state.groups.map (group, i) =>
            <NavItem key={i} eventKey={group.gid}>{group.name}</NavItem>}
        </Nav>
      </Col>
      <Col xs={10}>
        {organizationView}
      </Col>
    </Grid>

module.exports = OrganizationManagementPage
