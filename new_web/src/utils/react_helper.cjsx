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

ReactHelper.ShowIf = ShowIf

module.exports = ReactHelper
