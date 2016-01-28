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

Breadcrumb = RB.Breadcrumb
BreadcrumbItem = RB.BreadcrumbItem

Select = require "react-select"

update = require 'react-addons-update'

_ = require 'underscore'

Problem = require './problem'

LinkedStateMixin = require 'react-addons-linked-state-mixin'

ReactHelper = require "../utils/react_helper"
ShowIf = ReactHelper.ShowIf
SessionStore = ReactHelper.SessionStore
SessionSet = ReactHelper.SessionSet

ViewerToolbar = React.createClass
  mixins: [History, LinkedStateMixin]

  propTypes:
    filteredProblems: React.PropTypes.array.isRequired
    problemPages: React.PropTypes.number.isRequired
    problemsPerPage: React.PropTypes.number.isRequired
    activePage: React.PropTypes.number.isRequired
    handlePageSelect: React.PropTypes.func.isRequired
    updateProblemsPerPage: React.PropTypes.func.isRequired
    updateProblemDisplayOptions: React.PropTypes.func.isRequired

  problemsPerPageOptions: _.map [4, 8, 16, 32], (n) -> {label: "#{n} per page", value: n}
  problemDisplayOptions: [
    {label: "Show solved", value: true, stringValue: "on"}
    {label: "Hide solved", value: false, stringValue: "off"}
  ]

  render: ->
    if @props.filteredProblems.length > 0
      firstProblem = _.first @props.filteredProblems
      <Row>
        <Col xs={8} style={marginLeft: "-15px"}>
          <span>
            <Breadcrumb className="pull-left">
              <BreadcrumbItem onClick={() => @history.push "/problems"}>
                Problems
              </BreadcrumbItem>

              <ShowIf truthy={_.all _.tail(@props.filteredProblems), (p) -> p.category == firstProblem.category}>
                <BreadcrumbItem onClick={() => @history.push "/problems/category/#{firstProblem.category}"}>
                  {firstProblem.category}
                </BreadcrumbItem>
              </ShowIf>

              <ShowIf truthy={@props.filteredProblems.length == 1}>
                <BreadcrumbItem active>
                  {firstProblem.name}
                </BreadcrumbItem>
              </ShowIf/>
            </Breadcrumb>
          </span>
          <ShowIf truthy={@props.filteredProblems.length > 1}>
            <div className="pull-right">
              <Select
                className="problem-page"
                options={@problemDisplayOptions}
                value={if @props.showSolvedProblems then "on" else "off"}
                valueKey="stringValue"
                onChange={@props.updateProblemDisplayOptions}
                clearable={false}
                searchable={false}/>
              <Select
                className="problem-page"
                options={@problemsPerPageOptions}
                value={@props.problemsPerPage}
                onChange={@props.updateProblemsPerPage}
                clearable={false}
                searchable={false}/>
            </div>
          </ShowIf>
        </Col>
        <Col xs={4}>
          <ShowIf truthy={@props.problemPages > 1}>
            <Pagination next prev last
              id="problem-pagination"
              className="pull-right"
              maxButtons={3}
              items={@props.problemPages}
              activePage={@props.activePage}
              onSelect={@props.handlePageSelect}/>
          </ShowIf>
        </Col>
      </Row>
    else
      <div/>

Viewer = React.createClass

  propTypes:
    problems: React.PropTypes.array.isRequired
    showFilter: React.PropTypes.func.isRequired

  getInitialState: ->
    activePage: 1
    problemsPerPage: SessionStore "problemsPerPage", 8
    showSolvedProblems: SessionStore "showSolvedProblems", false

  handlePageSelect: (e, selectedEvent) ->
    @setState update @state, $set: activePage: selectedEvent.eventKey

  updateProblemDisplayOptions: (option) ->
    @setState update @state, $set: showSolvedProblems: (SessionSet "showSolvedProblems", option.value)

  updateProblemsPerPage: (option) ->
    @setState update @state, $set: problemsPerPage: (SessionSet "problemsPerPage", option.value)

  render: ->
    filteredProblems = @props.showFilter @props.problems

    if not @state.showSolvedProblems and filteredProblems.length > 1
      displayFilteredProblems = _.filter filteredProblems, (p) -> !p.solved
    else
      displayFilteredProblems = filteredProblems

    problemPages = Math.max(parseInt((displayFilteredProblems.length - 1) / @state.problemsPerPage), 0) + 1

    activeIndex = @state.activePage - 1
    startOfPage = activeIndex * @state.problemsPerPage
    shownProblems = displayFilteredProblems[startOfPage ... startOfPage + @state.problemsPerPage]

    <div>
      <ViewerToolbar
        handlePageSelect={@handlePageSelect}
        activePage={@state.activePage}
        filteredProblems={filteredProblems}
        updateProblemsPerPage={@updateProblemsPerPage}
        showSolvedProblems={@state.showSolvedProblems}
        updateProblemDisplayOptions={@updateProblemDisplayOptions}
        problemsPerPage={@state.problemsPerPage}
        problemPages={problemPages}
        {...@props}/>

      <Row id="problem-list">
        {_.map shownProblems, (problem) =>
          <Problem
            key={problem.pid}
            onProblemChange={@props.onProblemChange}
            {...problem}/>}
      </Row>
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
