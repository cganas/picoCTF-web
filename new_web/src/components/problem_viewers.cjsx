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
Pagination = RB.Pagination

update = require 'react-addons-update'

_ = require 'underscore'

Problem = require './problem'

ReactHelper = require "../utils/react_helper"

Viewer = React.createClass

  problemsPerPage: 4

  propTypes:
    problems: React.PropTypes.array.isRequired
    showFilter: React.PropTypes.func.isRequired

  getInitialState: ->
    activePage: 1

  handlePageSelect: (e, selectedEvent) ->
    @setState
      activePage: selectedEvent.eventKey

  render: ->
    filteredProblems = @props.showFilter @props.problems
    problemPages = parseInt (filteredProblems.length / @problemsPerPage)

    activeIndex = @state.activePage - 1
    startOfPage = activeIndex * @problemsPerPage
    shownProblems = filteredProblems.slice startOfPage, startOfPage + @problemsPerPage

    <div>
      <ReactHelper.ShowIf truthy={problemPages > 1}>
        <Pagination first next prev last ellipsis
          maxButtons={5}
          items={problemPages}
          activePage={@state.activePage}
          onSelect={@handlePageSelect}/>
      </ReactHelper.ShowIf>
      <div id="problem-list">
        {_.map shownProblems, (problem) =>
          <Problem
            key={problem.pid}
            onProblemChange={@props.onProblemChange}
            {...problem}/>}
      </div>
    </div>

ProblemViewer = React.createClass
  showProblemFilter: (problems) ->
    _.filter problems, (problem) =>
      problem.pid == @props.params.pid

  render: ->
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
