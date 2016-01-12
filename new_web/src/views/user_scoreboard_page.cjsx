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

update = require 'react-addons-update'


Api = require '../utils/api'

UserScoreboard = React.createClass

  getInitialState: ->
    public: []
    groups: []
    ineligible: []

  componentWillMount: ->
    Api.call "GET", "/api/stats/scoreboard"
    .done (resp) =>
      if resp.status == "error"
        Api.notify resp
      else
        @setState resp.data

  render: ->
    console.log @state
    <p>init</p>

module.exports = UserScoreboard
