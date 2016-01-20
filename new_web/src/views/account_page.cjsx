React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'
Grid = RB.Grid
Col = RB.Col
Row = RB.Row


TeamManagementForm = require '../components/team_management_form'
DisableAccountForm = require '../components/disable_account_form'
OrganizationManagementForm = require '../components/organization_management_form'
UpdatePasswordForm = require '../components/update_password_form'

update = require 'react-addons-update'

Api = require '../utils/api'

ReactHelper = require "../utils/react_helper"

AccountPage = React.createClass
    render: ->
      <Grid>
        <Col xs={6} style={paddingRight: 40}>
          <Row>
            <TeamManagementForm {...@props}/>
          </Row>
          <Row>
            <DisableAccountForm {...@props}/>
          </Row>
        </Col>
        <Col xs={6}>
          <Row>
            <UpdatePasswordForm {...@props}/>
          </Row>
          <Row>
            <OrganizationManagementForm {...@props}/>
          </Row>
        </Col>
      </Grid>

module.exports = AccountPage
