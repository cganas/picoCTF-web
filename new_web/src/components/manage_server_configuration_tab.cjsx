React = require 'react'

update = require 'react-addons-update'

DateTimeField = require 'react-bootstrap-datetimepicker'
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
Well = RB.Well
ButtonGroup = RB.ButtonGroup

Tabs = RB.Tabs
Tab = RB.Tab

EmailWhitelist = require "./email_whitelist"

_ = require 'underscore'
$ = require 'jquery'

Api = require '../utils/api'

ShowIf = (require "../utils/react_helper").ShowIf

GeneralTab = React.createClass
  mixins: [LinkedStateMixin]

  propTypes:
    refresh: React.PropTypes.func.isRequired
    settings: React.PropTypes.object.isRequired

  getInitialState: ->
    @props.settings

  toggleFeedbackEnabled: ->
    @setState update @state,
      $set: enable_feedback: !@state.enable_feedback

  updateStartTime: (value) ->
    @setState update @state,
      $set: start_time: $date: value

  updateEndTime: (value) ->
    @setState update @state,
      $set: end_time: $date: value

  pushUpdates: ->
    Api.call "POST", "/api/admin/settings/change", {json: JSON.stringify(@state)}
    .done (data) =>
      Api.notify data
      @props.refresh()

  render: ->
      # <TimeEntry name="Competition Start Time" value={@state.start_time["$date"]} onChange=@updateStartTime description={startTimeDescription}/>
      # <TimeEntry name="Competition End Time" value={@state.end_time["$date"]} onChange=@updateEndTime description={endTimeDescription}/>
    <Well>
      <Input type="checkbox" label="Receive Problem Feedback" valueLink={@linkState "enable_feedback"}/>
      <Row>
        <div className="text-center">
          <ButtonToolbar>
            <Button onClick={@pushUpdates}>Update</Button>
          </ButtonToolbar>
        </div>
      </Row>
    </Well>

EmailTab = React.createClass
  mixins: [LinkedStateMixin]

  propTypes:
    refresh: React.PropTypes.func.isRequired
    emailSettings: React.PropTypes.object.isRequired
    loggingSettings: React.PropTypes.object.isRequired
    emailFilterSettings: React.PropTypes.array.isRequired

  getInitialState: ->
    settings = @props.emailSettings
    $.extend settings, @props.loggingSettings
    settings.email_filter = @props.emailFilterSettings
    settings

  pushUpdates: (makeChange) ->
    pushData =
      email:
        enable_email: @state.enable_email
        email_verification: @state.email_verification
        smtp_url: @state.smtp_url
        smtp_port: @state.smtp_port
        email_username: @state.email_username
        email_password: @state.email_password
        from_addr: @state.from_addr
        from_name: @state.from_name
        smtp_security: @state.smtp_security
      logging:
        admin_emails: @state.admin_emails
      email_filter: @state.email_filter

    if typeof(makeChange) == "function"
      pushData = makeChange pushData

    Api.call "POST", "/api/admin/settings/change", {json: JSON.stringify(pushData)}
    .done (data) =>
      apiNotify data
      @props.refresh()

  render: ->

    # This is pretty bad. Much of this file needs reworked.
    if @state.smtp_security == "TLS"
        securityOptions =
        <Input type="select" valueLink={@linkState "smtp_security"} key="TLS">
          <option value="TLS">TLS</option>
          <option value="SSL">SSL</option>
        </Input>
    else
        securityOptions =
        <Input type="select" valueLink={@linkState "smtp_security"} key="SSL">
          <option value="SSL">SSL</option>
          <option value="TLS">TLS</option>
        </Input>

    SMTPSecuritySelect =
    <Row>
      <Col md={4}>
        <h4 className="pull-left">
          Security
        </h4>
      </Col>
      <Col md={8}>
        {securityOptions}
      </Col>
    </Row>

    <Well>
      <Row>
        <Col xs={6}>
          <Input type="radio" label="Send Emails?" valueLink={@linkState "enable_email"}/>
          <Input type="text" label="SMTP URL" valueLink={@linkState "smtp_url"}/>
          <Input type="number" label="SMTP Port" valueLink={@linkState "smtp_port"}/>
          <Input type="text" label="Email Username" valueLink={@linkState "email_username"}/>
          <Input type="text" label="Email Password" valueLink={@linkState "email_password"}/>
          <Input type="text" label="From Email Address" valueLink={@linkState "from_addr"}/>
          <Input type="text" label="From Name" valueLink={@linkState "from_name"}/>
          <Input type="radio" label="Email Verification?" valueLink={@linkState "enable_email"}/>
          {SMTPSecuritySelect}
          <Row>
            <div className="text-center">
              <ButtonToolbar>
                <Button onClick={@pushUpdates}>Update</Button>
              </ButtonToolbar>
            </div>
          </Row>
        </Col>
        <Col xs={6}>
          <EmailWhitelist pushUpdates={@pushUpdates} emails={@props.emailFilterSettings}/>
        </Col>
      </Row>
    </Well>

SettingsTab = React.createClass
  getInitialState: ->
    settings:
      start_time:
        $date: 0
      end_time:
        $date: 0
      enable_feedback: true
      email:
        email_verification: false
        enable_email: false
        from_addr: ""
        smtp_url: ""
        smtp_port: 0
        email_username: ""
        email_password: ""
        from_name: ""
      logging:
        admin_emails: []
      email_filter: []

    tabKey: "general"

  onTabSelect: (tab) ->
    @setState update @state,
      tabKey:
        $set: tab

  refresh: ->
    Api.call "GET", "/api/admin/settings"
    .done (api) =>
      @setState update @state,
        $set:
          settings: api.data

  componentDidMount: ->
    @refresh()

  render: ->
    generalSettings =
      enable_feedback: @state.settings.enable_feedback
      start_time: @state.settings.start_time
      end_time: @state.settings.end_time

    <Well>
      <Grid>
        <Row>
          <h4> Configure the competition settings by choosing a tab below </h4>
        </Row>
        <Tabs activeKey={@state.tabKey} onSelect={@onTabSelect}>
          <Tab eventKey='general' tab='General'>
            <GeneralTab refresh={@refresh} settings={generalSettings} key={Math.random()}/>
          </Tab>
          <Tab eventKey='email' tab='Email'>
            <EmailTab refresh={@refresh} emailSettings={@state.settings.email} emailFilterSettings={@state.settings.email_filter}
              loggingSettings={@state.settings.logging} key={Math.random()}/>
          </Tab>
        </Tabs>
      </Grid>
    </Well>

module.exports = SettingsTab
