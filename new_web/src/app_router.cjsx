React = require 'react'
ReactDom = require 'react-dom'

ReactRouter = require 'react-router'
Router = ReactRouter.Router
Route = ReactRouter.Route
IndexRoute = ReactRouter.IndexRoute

#Chrome dev-tools
@React = React

App = require './app'
FrontPage = require './views/front_page'

ReactDom.render (
  <Router>
    <Route path="/" component={App}>
      <IndexRoute component={FrontPage}/>
    </Route>
  </Router>
), document.getElementById 'app'

