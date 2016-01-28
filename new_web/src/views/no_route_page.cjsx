React = require 'react'

Link = (require "react-router").Link
Grid = (require "react-bootstrap").Grid

NoRoutePage = React.createClass
  render: ->
    <Grid>
      <h1>404 - No route found!</h1>
      <p>We were unable to find the page you were looking before. <Link to="/">This</Link> will take you back to the front page.</p>
    </Grid>

module.exports = NoRoutePage
