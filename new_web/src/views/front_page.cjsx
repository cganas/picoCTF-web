React = require 'react'

class FrontPage extends React.Component
  render: ->
    <div>
      <p>Front Page</p>
      {JSON.stringify(@props.status)}
    </div>

module.exports = FrontPage
