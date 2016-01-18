React = require 'react'

RB = require "react-bootstrap"
Glyphicon = RB.Glyphicon


ShowIf = (require "../utils/react_helper").ShowIf

Hint = React.createClass
  propTypes:
    hint: React.PropTypes.string.isRequired
    isShown: React.PropTypes.bool.isRequired
    onClick: React.PropTypes.func.isRequired

  getInitialState: ->
    extended: false

  onHintClick: ->

    #Only trigger on first click
    if not @state.extended
      @props.onClick()

    @setState extended: true
  render: ->
    <ShowIf truthy={@props.isShown}>
      <div>
        <Glyphicon
          style={paddingRight: 5}
          glyph="question-sign"
          onClick={@onHintClick}/>
        <ShowIf truthy={@state.extended}>
          <span dangerouslySetInnerHTML={__html: @props.hint}/>
        </ShowIf>
      </div>
    </ShowIf>

HintStore = React.createClass
  propTypes:
    hints: React.PropTypes.array.isRequired

  getInitialState: ->
    visibleHints: 0

  accumulateHints: ->
    @setState visibleHints: @state.visibleHints+1

  render: ->
    <div>
      <ShowIf truthy={@props.hints.length > 0}>
        <strong><small>Hints:</small></strong>
      </ShowIf>
      {@props.hints.map (hint, i) =>
        <Hint
          key={i}
          hint={hint}
          isShown={i <= @state.visibleHints}
          onClick={@accumulateHints}/>}
    </div>

module.exports = HintStore
