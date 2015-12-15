React = require 'react'
ReactDOM = require 'react-dom'

History = (require "react-router").History
Link = (require "react-router").Link

RB = require 'react-bootstrap'

Glyphicon = RB.Glyphicon
Panel = RB.Panel
Input = RB.Input
Row = RB.Row
Col = RB.Col
Button = RB.Button
Grid = RB.Grid

Popover = RB.Popover
Overlay = RB.Overlay

update = require 'react-addons-update'

_ = require 'underscore'

Problem = require './problem'

Viewer = React.createClass

  propTypes:
    problems: React.PropTypes.array.isRequired
    showFilter: React.PropTypes.func.isRequired

  render: ->
    shownProblems = @props.showFilter(@props.problems)

    <div id="problem-list">
      {_.map shownProblems, (problem) =>
        <Problem key={problem.pid} {...problem}/>}
    </div>

ProblemViewer = React.createClass
  showProblemFilter: (problems) ->
    _.filter problems, (problem) =>
      problem.pid == @props.params.pid

  render: ->
    console.log "problem"
    <Viewer showFilter={@showProblemFilter} {...@props}/>

DefaultProblemViewer = React.createClass
  render: ->
    <Viewer showFilter={_.identity} {...@props}/>

CategoryViewer = React.createClass
  showCategoryFilter: (problems) ->
    _.filter problems, (problem) =>
      problem.category == @props.params.category

  render: ->
    <Viewer showFilter={@showCategoryFilter} {...@props}/>

module.exports =
  DefaultProblemViewer: DefaultProblemViewer
  CategoryViewer: CategoryViewer
  ProblemViewer: ProblemViewer
