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

Problem = React.createClass
  propTypes: ->
    name: React.PropTypes.string.isRequired
    description: React.PropTypes.string.isRequired
    score: React.PropTypes.number.isRequired
    author: React.PropTypes.string.isRequired

  makeHeader: ->
    <div>
      {@props.name} <span className="pull-right">{@props.score}</span>
    </div>

  render: ->
    <Panel header={@makeHeader()}>
      <div dangerouslySetInnerHTML={__html: @props.description}/>
    </Panel>

module.exports = Problem
