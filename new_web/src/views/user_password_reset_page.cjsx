React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'

Glyphicon = RB.Glyphicon
Panel = RB.Panel
Input = RB.Input
ButtonInput = RB.ButtonInput
Row = RB.Row
Col = RB.Col
Button = RB.Button
Grid = RB.Grid

update = require 'react-addons-update'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

Api = require '../utils/api'

UserPasswordResetPage = React.createClass
  mixins: [LinkedStateMixin, History]

  getInitialState: ->
    username: ""

  onPasswordReset: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/user/reset_password", {username: @state.username}
    .done (resp) =>
      Api.notify resp
      if resp.status == "success"
        @history.push "/login"

  onPasswordResetConfirmation: (e) ->
    e.preventDefault()

    data =
      "new-password": @state.newPassword
      "new-password-confirmation": @state.newPasswordConfirmation
      "reset-token": @props.params.token

    Api.call "POST", "/api/user/confirm_password_reset", data
    .done (resp) =>
      Api.notify resp
      if resp.status == "success"
        @history.push "/login"

  render: ->
    userGlyph = <Glyphicon glyph="user"/>
    lockGlyph = <Glyphicon glyph="lock"/>

    if not @props.params.token?
      <Grid>
        <Panel>
          <form onSubmit={@onPasswordReset}>
            <p><i>A password reset link will be sent the users email.</i></p>
            <Input type="text" valueLink={@linkState "username"} addonBefore={userGlyph} placeholder="Username" required="visible"/>
            <Row>
              <Col md={6}>
                <Button type="submit">Reset Password</Button>
              </Col>
              <Col md={6}>
                <span className="pull-right pad">Go back to <a onClick={() => @history.push "/login"}>Login</a>.</span>
              </Col>
            </Row>
          </form>
        </Panel>
      </Grid>
    else
      <Grid>
        <Panel>
          <form onSubmit={@onPasswordResetConfirmation}>
            <Input type="password" valueLink={@linkState "newPassword"} addonBefore={lockGlyph} placeholder="Password" required="visible"/>
            <Input type="password" valueLink={@linkState "newPasswordConfirmation"} addonBefore={lockGlyph} placeholder="Confirm Password" required="visible"/>
            <Row>
              <Col md={6}>
                <Button type="submit">Update Password</Button>
              </Col>
              <Col md={6}>
                <span className="pull-right pad">Go back to <a onClick={() => @history.push "/login"}>Login</a>.</span>
              </Col>
            </Row>
          </form>
        </Panel>
      </Grid>

module.exports = UserPasswordResetPage
