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

ProblemPage = require "./views/problem_page"

ProblemViewers = require "./components/problem_viewers"

ReactDom.render (
  <Router history={createBrowserHistory()}>
    <Route path="/" component={App}>
      <Route path="login" component={UserLoginPage}/>
      <Route path="register" component={UserRegistrationPage}/>
      <Route path="problems" component={ProblemPage}>
        <IndexRoute component={ProblemViewers.DefaultProblemViewer}/>
        <Route path="category/:category" component={ProblemViewers.CategoryViewer}/>
        <Route path=":pid" component={ProblemViewers.ProblemViewer}/>
      </Route>
      <IndexRoute component={FrontPage}/>
    </Route>
  </Router>
), document.getElementById 'app'

