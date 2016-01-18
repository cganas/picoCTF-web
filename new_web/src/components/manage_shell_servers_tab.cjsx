React = require 'react'

LinkedStateMixin = require 'react-addons-linked-state-mixin'

History = (require "react-router").History

RB = require 'react-bootstrap'

ListGroupItem = RB.ListGroupItem
ListGroup = RB.ListGroup
Accordion = RB.Accordion
Panel = RB.Panel
Button = RB.Button
Glyphicon = RB.Glyphicon
Grid = RB.Grid
Row = RB.Row
Col = RB.Col
Badge = RB.Badge
Input = RB.Input
Button = RB.Button
ButtonToolbar = RB.ButtonToolbar
Well = RB.Well
Accordion = RB.Accordion

_ = require 'underscore'

Api = require '../utils/api'

ShowIf = (require "../utils/react_helper").ShowIf

ServerForm = React.createClass
  mixins: [LinkedStateMixin]
  propTypes:
    new: React.PropTypes.bool.isRequired
    refresh: React.PropTypes.func.isRequired
    server: React.PropTypes.object

  getInitialState: ->
    if @props.new
      {"host": "", "port": 22, "username": "", "password": "", "protocol": "HTTP", "name": ""}
    else
      @props.server


  notifyAndRefresh: (data) ->
    Api.notify data
    @props.refresh()

  addServer: ->
    Api.call "POST", "/api/admin/shell_servers/add", @state
    .done @notifyAndRefresh

  deleteServer: ->
    Api.call "POST", "/api/admin/shell_servers/remove", {"sid": @state.sid}
    .done @notifyAndRefresh

  updateServer: ->
    Api.call "POST", "/api/admin/shell_servers/update", @state
    .done @notifyAndRefresh

  loadProblems: ->
    Api.call "POST", "/api/admin/shell_servers/load_problems", {"sid": @state.sid}
    .done @notifyAndRefresh

  checkStatus: ->
    Api.call "GET", "/api/admin/shell_servers/check_status", {"sid": @state.sid}
    .done Api.notify

  render: ->
    <div>
      <ShowIf truthy={@props.new}>
        <Input type="text" label="Name" valueLink={@linkState "name"}/>
      </ShowIf>

      <Input type="text" label="Host" valueLink={@linkState "host"}/>
      <Input type="number" label="SSH Port" valueLink={@linkState "port"}/>
      <Input type="text" label="Username" valueLink={@linkState "username"}/>
      <Input type="text" label="Password" valueLink={@linkState "password"}/>
      <Input type="select" label="Web Security" placeholder="HTTP" valueLink={@linkState "protocol"}>
        <option value="HTTP">HTTP</option>
        <option value="HTTPS">HTTPS</option>
      </Input>

      <ShowIf truthy={@props.new}>
        <ButtonToolbar className="pull-right">
          <Button onClick={@addServer}>Add</Button>
        </ButtonToolbar>
      </ShowIf>

      <ShowIf truthy={!@props.new}>
        <ButtonToolbar className="pull-right">
          <Button onClick={@updateServer}>Update</Button>
          <Button onClick={@deleteServer}>Delete</Button>
          <Button onClick={@loadProblems}>Load Deployment</Button>
          <Button onClick={@checkStatus}>Check Status</Button>
        </ButtonToolbar>
      </ShowIf>
    </div>

ShellServerList = React.createClass

  getInitialState: ->
    shellServers: []

  refresh: ->
    Api.call "GET", "/api/admin/shell_servers"
    .done (api) =>
      @setState {shellServers: api.data}

  componentDidMount: ->
    @refresh()

  createShellServerForm: (server, i) ->
    if server
      shellServer = <ServerForm new={false} server={server} key={server.sid} refresh={@refresh}/>
      header = <div>{server.name} - {server.host}</div>
    else
      shellServer = <ServerForm new={true} key={i+"new"} refresh={@refresh}/>
      header = <div> New Shell Server </div>

    <Panel bsStyle="default" eventKey={i} key={i} header={header}>
      {shellServer}
    </Panel>

  render: ->
    serverList = _.map @state.shellServers, @createShellServerForm
    serverList.push(@createShellServerForm(null, @state.shellServers.length))

    <Accordion defaultActiveKey={0}>
      {serverList}
    </Accordion>

ShellServersTab = React.createClass

  render: ->
    <Well>
      <Grid>
        <Row>
          <h4>To add problems, enter your shell server information below.</h4>
        </Row>
        <Row>
          <Col md={6}>
            <ShellServerList/>
          </Col>
        </Row>
      </Grid>
    </Well>

module.exports = ShellServersTab
