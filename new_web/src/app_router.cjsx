React = require 'react'
ReactDom = require 'react-dom'

ReactRouter = require 'react-router'
Router = ReactRouter.Router
Route = ReactRouter.Route
IndexRoute = ReactRouter.IndexRoute

createBrowserHistory = require "history/lib/createBrowserHistory"

#Chrome dev-tools
@React = React

App = require './app'
FrontPage = require './views/front_page'
UserRegistrationPage = require './views/user_registration_page'
UserLoginPage = require "./views/user_login_page"

ReactDom.render (
  <Router history={createBrowserHistory()}>
    <Route path="/" component={App}>
      <Route path="login" component={UserLoginPage}/>
      <Route path="register" component={UserRegistrationPage}/>
      <IndexRoute component={FrontPage}/>
    </Route>
  </Router>
), document.getElementById 'app'

