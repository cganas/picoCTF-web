React = require 'react'

_ = require 'underscore'

update = require 'react-addons-update'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

Api = require '../utils/api'

RB = require "react-bootstrap"

Input = RB.Input
Row = RB.Row
Col = RB.Col
Button = RB.Button
ButtonGroup = RB.ButtonGroup
Panel = RB.Panel
ListGroup = RB.ListGroup
ListGroupItem = RB.ListGroupItem
Glyphicon = RB.Glyphicon

ShowIf = (require "../utils/react_helper").ShowIf

ManageOrganization = React.createClass
  getInitialState: ->
    members: []
    teachers: []
    settings:
      email_filter: []
      hidden: false

  onGroupChange: ->
    Api.call "GET", "/api/group/settings", {gid: @props.gid}
    .done (resp) =>
      if resp.status == "success"
        @setState update @state, $merge: settings: resp.data
      else
        Api.notify resp

    Api.call "GET", "/api/group/member_information", {gid: @props.gid}
    .done (resp) =>
      if resp.status == "success"
        @setState update @state, $set: members: resp.data
      else
        Api.notify resp

    Api.call "GET", "/api/group/teacher_information", {gid: @props.gid}
    .done (resp) =>
      if resp.status == "success"
        @setState update @state, $set: teachers: resp.data
      else
        Api.notify resp

  pushUpdates: (modifier) ->
    data = @state

    if modifier
      data.settings = modifier data.settings

    Api.call "POST", "/api/group/settings", {gid: @props.gid, settings: JSON.stringify data.settings}
    .done (resp) =>
      Api.notify resp
      @onGroupChange

  componentWillMount: ->
    @onGroupChange()

  render: ->
    <div>
      <Col xs={6}>
        <MemberManagement
          gid={@props.gid}
          members={@state.members}
          teachers={@state.teachers}
          currentUser={@props.userStatus}
          onGroupChange={@onGroupChange}/>
      </Col>
      <Col xs={6}>
        {@props.gid}
      </Col>
    </div>

MemberManagement = React.createClass

  render: ->
    console.log @props.gid
    allMembers = update @props.teachers, $push: @props.members
    allMembers = _.filter allMembers, (member) => @props.currentUser["tid"] != member["tid"]

    <div>
      <h4>User Management</h4>
      <MemberInvitePanel {...@props}/>
      <ListGroup>
        {allMembers.map (member, i) =>
          <MemberManagementItem
            key={@props.gid+i}
            {...member}
            {...@props}/>}
      </ListGroup>
    </div>

MemberManagementItem = React.createClass
  removeTeam: ->
    Api.call "POST", "/api/group/teacher/leave", {gid: @props.gid, tid: @props.tid}
    .done (resp) =>
      Api.notify resp
      @props.onGroupChange()

  switchUserRole: (tid, role) ->
    apiCall "POST", "/api/group/teacher/role_switch", {gid: @props.gid, tid: tid, role: role}
    .done (resp) =>
      Api.notify resp
      @props.onGroupChange()

  render: ->
    <ListGroupItem>
      <Row>
        <Col xs={2}>
          <ShowIf truthy={@props.teacher}>
            <Button bsStyle="success" className="btn-sq">
              <Glyphicon glyph="user" bsSize="large"/>
              <p className="text-center">Coach</p>
            </Button>
          </ShowIf>
          <ShowIf truthy={!@props.teacher}>
            <Button bsStyle="primary" className="btn-sq">
              <Glyphicon glyph="user" bsSize="large"/>
              <p className="text-center">User</p>
            </Button>
          </ShowIf>
        </Col>
        <Col xs={6}>
          <h4>{@props.team_name}</h4>
          <p><strong>Affiliation:</strong> {@props.affiliation}</p>
        </Col>
        <Col xs={4}>
          <ButtonGroup vertical>
            <ShowIf truthy={@props.teacher}>
              <Button onClick={@switchUserRole.bind(null, @props.tid, "member")}>Make Member</Button>
            </ShowIf>
            <ShowIf truthy={!@props.teacher}>
              <Button onClick={@switchUserRole.bind(null, @props.tid, "teacher")}>Make Coach</Button>
            </ShowIf>
            <Button onClick={@removeTeam}>Remove User</Button>
          </ButtonGroup>
        </Col>
      </Row>
    </ListGroupItem>

MemberInvitePanel = React.createClass
  mixins: [LinkedStateMixin]

  propTypes:
    gid: React.PropTypes.string.isRequired

  getInitialState: ->
    role: "member"

  inviteUser: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/group/invite", {gid: @props.gid, email: @state.email, role: @state.role}
    .done (resp) =>
      Api.notify resp
      @setState update @state, $set: email: ""
      @props.onGroupChange()

  render: ->
    <Panel>
      <form onSubmit={@inviteUser}>
        <Col xs={8}>
          <Input type="email" label="E-mail" valueLink={@linkState "email"}/>
        </Col>
        <Col xs={4}>
          <Input type="select" label="Role" placeholder="Member" valueLink={@linkState "role"}>
            <option value="member">Member</option>
            <option value="teacher">Teacher</option>
          </Input>
        </Col>
        <Col xs={4}>
          <Button onClick={@inviteUser}>Invite User</Button>
        </Col>
      </form>
    </Panel>

module.exports = ManageOrganization
