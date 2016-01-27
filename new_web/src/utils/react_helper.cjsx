React = require 'react'

ReactHelper = {}

ShowIf = React.createClass
  propTypes:
    f: React.PropTypes.func
    truthy: React.PropTypes.bool

  render: ->
    if @props.truthy or (@props.f and @props.f())
      @props.children
    else
      <span className="hidden"/>

SessionSet = (key, value) ->
  localStorage[key] = JSON.stringify value
  value

SessionGet = (key) ->
  JSON.parse localStorage[key]

SessionStore = (key, def) ->
  if localStorage[key]?
    SessionGet key
  else if def?
    SessionSet key, def


ReactHelper.SessionStore = SessionStore
ReactHelper.SessionSet = SessionSet
ReactHelper.SessionGet = SessionGet

ReactHelper.ShowIf = ShowIf

module.exports = ReactHelper
