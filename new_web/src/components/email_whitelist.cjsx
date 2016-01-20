React = require 'react'

LinkedStateMixin = require 'react-addons-linked-state-mixin'

RB = require 'react-bootstrap'

ListGroupItem = RB.ListGroupItem
ListGroup = RB.ListGroup
Glyphicon = RB.Glyphicon
Col = RB.Col
Row = RB.Row
Input = RB.Input
Button = RB.Button
Well = RB.Well
Glyphicon = RB.Glyphicon

update = require 'react-addons-update'

Api = require '../utils/api'

_ = require 'underscore'

EmailWhitelistItem = React.createClass
  propTypes:
    email: React.PropTypes.string.isRequired
    pushUpdates: React.PropTypes.func.isRequired

  render: ->
    removeEmail = @props.pushUpdates.bind null, (data) =>
      update data, {email_filter: {$apply: _.partial _.without, _, @props.email}}

    <ListGroupItem>
      *@{@props.email}
      <span className="pull-right"><Glyphicon glyph="remove" onClick={removeEmail}/></span>
    </ListGroupItem>

EmailWhitelist = React.createClass
  mixins: [LinkedStateMixin]

  getInitialState: ->
    {}

  propTypes:
    pushUpdates: React.PropTypes.func.isRequired
    emails: React.PropTypes.array.isRequired

  addEmailDomain: (e) ->
    # It would probably make more sense to this kind of validation server side.
    # However, it can't cause any real issue being here.

    #asd
    e.preventDefault()

    if _.indexOf(@props.emails, @state.emailDomain) != -1
      Api.notify {status: "error", message: "This email domain has already been whitelisted."}
    else if _.indexOf(@state.emailDomain, "@") != -1
      Api.notify {status: "error", message: "You should not include '@'. I want the email domain that follows '@'."}
    else if _.indexOf(@state.emailDomain, ".") == -1
        Api.notify {status: "error", message: "Your email domain did not include a '.' as I expected. Please make sure this is an email domain."}
    else
      @props.pushUpdates (data) =>
        update data, email_filter: $push: [@state.emailDomain]

  createItemDisplay: ->
    <ListGroup>
      {@props.emails.map (email, i) =>
        <EmailWhitelistItem key={i} email={email} pushUpdates={@props.pushUpdates}/>}
    </ListGroup>

  render: ->
    emptyItemDisplay =
      <p>The whitelist is current empty. All emails will be accepted during registration.</p>

    <div>
      <h4>Email Domain Whitelist</h4>
      <form onSubmit={@addEmailDomain}>
        <Row>
          <Input type="text" addonBefore="@ Domain" valueLink={@linkState "emailDomain"}/>
        </Row>
        <Row>
          {if @props.emails.length > 0 then @createItemDisplay() else emptyItemDisplay}
        </Row>
      </form>
    </div>

module.exports = EmailWhitelist
