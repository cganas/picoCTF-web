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
Select = require "react-select"

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
      noOrganization: false
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

    data = @state
    if @state.noOrganization
      data.affiliation = "N/A"
    else
      data.affiliation = (@getGroup @state.gid).name

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

  getGroup: (gid) ->
    _.find @state.allGroups, (group) => group.gid == gid

  render: ->

    userGlyph = <Glyphicon glyph="user"/>
    lockGlyph = <Glyphicon glyph="lock"/>

    activeOrganization = @getGroup @state.gid

    if @state.teamSettings? and @state.teamSettings.email_filter.length > 0
      emailBanner =
      <Alert>
        You <strong>must</strong> have an email from one of these domains to register: <strong>{@state.teamSettings.email_filter.join ", "}</strong>.
      </Alert>

    if activeOrganization?
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
    else
      selectedLabel =
      <label style={width: "100%"}>
        Organization <span className="pull-right no-org"><Input type="checkbox" label="I am not with an organization."
          checked={@state.noOrganization} onChange={() => @setState update @state, $set: noOrganization: !@state.noOrganization}/></span>
      </label>

    console.log @state

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
          <ShowIf truthy={not activeOrganization? and @state.teamSettings? and @state.teamSettings.email_filter.length > 0}>
            {emailBanner}
          </ShowIf>

          <ShowIf truthy={@state.gid? and not activeOrganization? and @state.allGroups.length > 0}>
            <Alert bsStyle="danger">Your invitation link does not encode for a valid group. Please check the integrity of your URL.</Alert>
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
              {selectedLabel}
              <Select
                name="form-field-name"
                options={_.map @state.allGroups, (g) -> {label: g.name, value: g.gid}}
                value={@state.gid}
                clearable={false}
                disabled={@state.noOrganization}
                onChange={(option) => @setState update @state, $set: gid: option.value}
              />
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
