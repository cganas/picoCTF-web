React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'

Glyphicon = RB.Glyphicon
Panel = RB.Panel
Input = RB.Input
Row = RB.Row
Col = RB.Col
Button = RB.Button
Grid = RB.Grid
Alert = RB.Alert
ButtonInput = RB.ButtonInput

ShowIf = (require "../utils/react_helper").ShowIf
Typeahead = require "../components/reasonable_typeahead"

update = require 'react-addons-update'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

_ = require 'underscore'
Api = require '../utils/api'

UserRegistrationPage = React.createClass
  mixins: [LinkedStateMixin, History]

  getInitialState: ->
    state =
      eligibility: "eligible"
      allGroups: []
      gid: @props.params.gid
      rid: @props.params.rid

  componentWillMount: ->
    Api.call "GET", "/api/team/settings"
    .success (resp) =>
      @setState update @state,
        teamSettings: $set: resp.data

    Api.call "GET", "/api/group/all"
    .success (resp) =>
      @setState update @state,
        allGroups: $set: resp.data

  onUserRegistration: (e) ->
    e.preventDefault()

    Api.call "POST", "/api/user/create_simple", @state
    .done (resp) =>
      Api.notify resp
      if resp.status == "success"
        @props.onStatusChange()
        if @props.status.email_verification
          Api.notify {status: "success", message: "You have received a verification email. Check your email to confirm your account."}
          @history.push "/login"
        else
          @history.push "/problems"

  onOrganizationSelect: (affiliation) ->
    organization = _.find @state.allGroups, (group) => group.name == affiliation
    @setState update @state, $set: gid: organization.gid

  onOrganizationRemove: ->
    @setState update @state, $set: gid: null

  render: ->

    console.log @state
    userGlyph = <Glyphicon glyph="user"/>
    lockGlyph = <Glyphicon glyph="lock"/>

    activeOrganization = _.find @state.allGroups, (group) => group.gid == @state.gid

    if activeOrganization
      emailBanner =
      <Alert>
        You <strong>must</strong> have an email from one of these domains to register with the {activeOrganization.name}: <strong>{activeOrganization.settings.email_filter.join ", "}</strong>.
      </Alert>

      removalButton =
      <Glyphicon
        style={color: "red"}
        onClick={@onOrganizationRemove}
        glyph="remove"/>

      selectedLabel =
      <label style={width: "100%"}>
        Organization <span className="pull-right">Selected: {activeOrganization.name} {removalButton}</span>
      </label>

    <Grid>
      <Panel>
        <form onSubmit={@onUserRegistration}>
          <Row>
            <Col md={6}>
              <Input type="text" id="username" valueLink={@linkState "username"} addonBefore={userGlyph} label="Username"/>
            </Col>
            <Col md={6}>
              <Input type="password" id="password" valueLink={@linkState "password"} addonBefore={lockGlyph} label="Password"/>
            </Col>
          </Row>
          <Row>
            <Col md={6}>
              <Input type="text" id="first-name" valueLink={@linkState "firstname"} label="First Name"/>
            </Col>
            <Col md={6}>
              <Input type="text" id="last-name" valueLink={@linkState "lastname"} label="Last Name"/>
            </Col>
          </Row>
          <ShowIf truthy={activeOrganization? and activeOrganization.settings.email_filter.length > 0 and !@state.rid}>
            {emailBanner}
          </ShowIf>
          <ShowIf truthy={!@state.rid}>
            <Row>
              <Col md={12}>
                <Input type="email" id="email" valueLink={@linkState "email"} label="E-mail"/>
              </Col>
            </Row>
          </ShowIf>
          <Row>
            <Col md={6}>
              <ShowIf truthy={activeOrganization?}>
                {selectedLabel}
              </ShowIf>
              <ShowIf truthy={!activeOrganization?}>
                <label>Organization</label>
              </ShowIf>
              <Typeahead
                options={_.map @state.allGroups, "name"}
                onOptionSelected={@onOrganizationSelect}
                value={if activeOrganization? then activeOrganization.name else null}/>
            </Col>
            <Col md={6}>
              <Input type="select" label="Status" placeholder="Competitor" valueLink={@linkState "eligibility"}>
                <option value="eligible">Competitor</option>
                <option value="ineligible">Instructor</option>
              </Input>
            </Col>
          </Row>
          <ButtonInput type="submit">Register</ButtonInput>
        </form>
      </Panel>
    </Grid>

module.exports = UserRegistrationPage
