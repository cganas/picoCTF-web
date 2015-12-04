React = require 'react'
ReactDom = require 'react-dom'

ReactRouter = require 'react-router'
Router = ReactRouter.Router
Route = ReactRouter.Route
DefaultRoute = ReactRouter.DefaultRoute

#Chrome dev-tools
@React = React

App = require './app'
FrontPage = require './views/front_page'

ReactDom.render (
  <Router>
    <Route path="/" component={App}>
      <Route path="test" component={FrontPage}/>
    </Route>
  </Router>
), document.getElementById 'app'

