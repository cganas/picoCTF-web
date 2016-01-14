React = require 'react'

update = require 'react-addons-update'

DateTimeField = require 'react-bootstrap-datetimepicker'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

History = (require "react-router").History

RB = require 'react-bootstrap'

Button = RB.Button
Grid = RB.Grid
Row = RB.Row
Col = RB.Col
Input = RB.Input
ButtonToolbar = RB.ButtonToolbar

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
    onUpdate: React.PropTypes.func.isRequired
    settings: React.PropTypes.object.isRequired

  getInitialState: ->
    @props.settings

  updateStartTime: (value) ->
    @setState update @state,
      $set: start_time: $date: value

  updateEndTime: (value) ->
    @setState update @state,
      $set: end_time: $date: value

  pushUpdates: ->
    @props.onUpdate @state

  render: ->
    <Col>
      <Row>
        <Input type="checkbox" label="Receive Problem Feedback" checkedLink={@linkState "enable_feedback"}/>
      </Row>
      <Row>
        <h4>Start Time</h4>
        <DateTimeField dateTime={@state.start_time["$date"]} onChange={@updateStartTime}/>
      </Row>
      <Row>
        <h4>End Time</h4>
        <DateTimeField dateTime={@state.end_time["$date"]} onChange={@updateEndTime}/>
      </Row>
      <br/>
      <Row>
        <ButtonToolbar>
          <Button onClick={@pushUpdates}>Update</Button>
        </ButtonToolbar>
      </Row>
    </Col>

EmailTab = React.createClass
  mixins: [LinkedStateMixin]

  propTypes:
    onUpdate: React.PropTypes.func.isRequired
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

    @props.onUpdate pushData

  render: ->

    # This is pretty bad. Much of this file needs reworked.
    if @state.smtp_security == "TLS"
        securityOptions =
        <Input label="Security" type="select" valueLink={@linkState "smtp_security"} key="TLS">
          <option value="TLS">TLS</option>
          <option value="SSL">SSL</option>
        </Input>
    else
        securityOptions =
        <Input label="Security" type="select" valueLink={@linkState "smtp_security"} key="SSL">
          <option value="SSL">SSL</option>
          <option value="TLS">TLS</option>
        </Input>

    <Row>
      <Col xs={6}>
        <Input type="checkbox" label="Send Emails?" checkedLink={@linkState "enable_email"}/>
        <Input type="checkbox" label="Email Verification?" checkedLink={@linkState "email_verification"}/>
        <Input type="text" label="SMTP URL" valueLink={@linkState "smtp_url"}/>
        <Input type="number" label="SMTP Port" valueLink={@linkState "smtp_port"}/>
        <Input type="text" label="Email Username" valueLink={@linkState "email_username"}/>
        <Input type="text" label="Email Password" valueLink={@linkState "email_password"}/>
        <Input type="text" label="From Email Address" valueLink={@linkState "from_addr"}/>
        <Input type="text" label="From Name" valueLink={@linkState "from_name"}/>
        {securityOptions}
        <br/>
        <Button onClick={@pushUpdates}>Update</Button>
      </Col>
      <Col xs={6}>
        <EmailWhitelist pushUpdates={@pushUpdates} emails={@props.emailFilterSettings}/>
      </Col>
    </Row>

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
    .done (resp) =>
      if resp.status == "success"
        @setState update @state,
          $set:
            settings: resp.data
      else
        Api.notify resp

  componentDidMount: ->
    @refresh()

  sendUpdateRequest: (updates) ->
    Api.call "POST", "/api/admin/settings/change", {json: JSON.stringify(updates)}
    .done (data) =>
      Api.notify data
      @refresh()

  render: ->
    generalSettings =
      enable_feedback: @state.settings.enable_feedback
      start_time: @state.settings.start_time
      end_time: @state.settings.end_time

    <Grid>
      <Col xs={10} xsOffset={1}>
        <Row>
          <h4 className="text-center"> Configure the competition settings by choosing a tab below </h4>
        </Row>
        <Row>
          <Tabs activeKey={@state.tabKey} onSelect={@onTabSelect}>
            <Tab eventKey='general' title='General'>
              <GeneralTab settings={generalSettings} onUpdate={@sendUpdateRequest} key={Math.random()}/>
            </Tab>
            <Tab eventKey='email' title='Email'>
              <EmailTab emailSettings={@state.settings.email} emailFilterSettings={@state.settings.email_filter}
                loggingSettings={@state.settings.logging} onUpdate={@sendUpdateRequest} key={Math.random()}/>
            </Tab>
          </Tabs>
        </Row>
      </Col>
    </Grid>

module.exports = SettingsTab
