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

_ = require 'underscore'

update = require 'react-addons-update'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

Api = require '../utils/api'

ProblemExplorer = require '../components/problem_explorer'

ProblemPage = React.createClass

  getInitialState: ->
    problems: []

  componentWillMount: ->
    Api.call "GET", "/api/problems"
    .done (resp) =>
      @setState update @state,
        $set: problems: resp.data

  render: ->

    problemView = React.cloneElement @props.children,
      problems: @state.problems

    <Grid fluid={true}>
      <Col xs={3}>
        <ProblemExplorer problems={@state.problems}/>
      </Col>
      <Col xs={9}>
        {problemView}
      </Col>
    </Grid>

module.exports = ProblemPage
