React = require 'react'

History = (require "react-router").History

FrontPage = React.createClass
  render: ->
    <div>
      <p>Front Page</p>
      {JSON.stringify(@props.status)}
    </div>

module.exports = FrontPage
