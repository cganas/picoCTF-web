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
LinkedStateMixin = require 'react-addons-linked-state-mixin'

Api = require '../utils/api'

ProblemListVisualizer = require '../componets/problem_list_visualizer'

ProblemViewer = React.createClass
  render: ->

    console.log "Problem"

    <div>
      problem {@props.params.pid}
    </div>

DefaultProblemViewer = React.createClass
  render: ->
    <div>
      default list of problems
    </div>

CategoryViewer = React.createClass
  render: ->

    console.log "Navigator"

    <div>
      navigator {@props.params.category}
    </div>

ProblemPage = React.createClass

  getInitialState: ->
    problems: []

  componentWillMount: ->
    Api.call "GET", "/api/problems"
    .done (resp) =>
      @setState update @state,
        $set: problems: resp.data

  render: ->

    problemView = @props.children

    <Grid fluid={true}>
      <Col xs={3}>
        <ProblemListVisualizer problems={@state.problems}/>
      </Col>
      <Col xs={9}>
        {problemView}
      </Col>
    </Grid>

ProblemPage =
  ProblemPage: ProblemPage
  ProblemListVisualizer: ProblemListVisualizer
  DefaultProblemViewer: DefaultProblemViewer
  CategoryViewer: CategoryViewer
  ProblemViewer: ProblemViewer

module.exports = ProblemPage
