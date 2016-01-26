Status = require "./status"

Api = require "./api"

Security =
  redirect: (pred, where, message) ->
    (nextState, replaceState) =>
      if pred()
        replaceState {nextPathname: nextState.location.pathname}, (where || "/")
        if message
          Api.notify {status: "error", message: message}

Security.MustBeLoggedIn = (where, message) ->
  Security.redirect (() -> !Status.getStatus().logged_in), (where || "/login"), (message || "You must be logged in to view this page.")

Security.MustBeAnAdmin = (where, message) ->
  Security.redirect (() -> !Status.getStatus().admin), where, (message || "You must be an admin to view this page.")

Security.MustBeATeacher = (where, message) ->
  Security.redirect (() -> !Status.getStatus().teacher), where, (message || "You must be a teacher to view this page.")

module.exports = Security
