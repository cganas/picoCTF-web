React = require 'react'
ReactDOM = require 'react-dom'

LinkedStateMixin = require 'react-addons-linked-state-mixin'

Link = (require "react-router").Link
History = (require "react-router").History

classNames = require 'classnames'

RB = require 'react-bootstrap'

Glyphicon = RB.Glyphicon
Panel = RB.Panel
Input = RB.Input
Row = RB.Row
Col = RB.Col
Button = RB.Button
Grid = RB.Grid
Badge = RB.Badge

HintStore = require "../components/hint_store"

History = (require "react-router").History

Api = require "../utils/api"

update = require 'react-addons-update'

_ = require 'underscore'

ReactHelper = require "../utils/react_helper"
ShowIf = ReactHelper.ShowIf
SessionStore = ReactHelper.SessionStore
SessionSet = ReactHelper.SessionSet
SessionGet = ReactHelper.SessionGet

Problem = React.createClass
  mixins: [LinkedStateMixin, History]

  propTypes: ->
    name: React.PropTypes.string.isRequired
    description: React.PropTypes.string.isRequired
    score: React.PropTypes.number.isRequired
    author: React.PropTypes.string.isRequired

  sessionKey: (key) ->
    if key then "#{@props.pid}.#{key}" else @props.pid

  getInitialState: ->
    key: ""
    expanded: SessionStore @sessionKey("expanded"), false

  onProblemSubmit: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/problems/submit", {pid: @props.pid, key: @state.key}
    .done (resp) =>
      Api.notify resp

      if resp.status == "success"
        SessionSet (@sessionKey "expanded"), false
        @setState update @state, $set: expanded: false

      @setState update @state, key: $set: ""
      @props.onProblemChange @props.pid

  render: ->
    problemClass = classNames(
      "panel-default": !@props.solved
      "panel-success": @props.solved,
      "panel": true
    )

    problemBodyClass = classNames(
      "panel-collapse": true,
      "collapse": true,
      "in": @state.expanded
    )

    to = (link, f) =>
      (e) =>
        if f?
          f()
        @history.push link
        e.stopPropagation()

    toggleExpand = (expanded) =>
      () =>
        SessionSet (@sessionKey "expanded"), (expanded || (!SessionGet (@sessionKey "expanded")))
        @setState update @state, $set: expanded: SessionGet (@sessionKey "expanded")

    <div className="panel-group">
      <div className={problemClass}>
        <div className="panel-heading" onClick={toggleExpand()}>
          <a onClick={to "/problems/#{@props.pid}", toggleExpand true}>
            <strong>{@props.name}</strong> {@props.score}
          </a>
          <a className="pull-right" onClick={to "/problems/category/#{@props.category}"}>
            {@props.category}
          </a>
        </div>
        <div className={problemBodyClass}>
          <div className="panel-body">
          <div style={paddingBottom: 20} dangerouslySetInnerHTML={__html: @props.description}/>
          <HintStore hints={@props.hints}/>
          <hr/>
          <ShowIf truthy={@props.solved}>
            <Input type="text" bsStyle="success" hasFeedback disabled/>
          </ShowIf>
          <ShowIf truthy={!@props.solved}>
            <form onSubmit={@onProblemSubmit}>
              <Input type="text"
                buttonBefore={<Button type="submit">Submit</Button>}
                valueLink={@linkState "key"}/>
            </form>
          </ShowIf>
          </div>
          <div className="panel-footer">
            <span>Written by {@props.author} at {@props.organization}</span>
            <span className="pull-right"><strong>Solves: {@props.solves}</strong></span>
          </div>
        </div>
      </div>
    </div>

module.exports = Problem
