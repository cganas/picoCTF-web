React = require 'react'

History = (require "react-router").History
Api = require '../utils/api'

UserLogoutPage = React.createClass
  mixins: [History]

  getInitialState: ->
    failure: undefined

  componentWillMount: ->
    Api.call "GET", "/api/user/logout"
    .done (resp) =>
      Api.notify resp
      @props.onStatusChange () =>
        @setState {failure: resp.status == "error"}
        if resp.status == "success"
          @history.push "/login"

  render: ->
    if @state.failure?
      <p>Logging out.</p>
    else
      <p>Logout unsuccessful. Please try again.</p>

module.exports = UserLogoutPage
