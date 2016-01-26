Api = require "./api"

module.exports =
  fetch: (refresh) ->
    Api.call "GET", "/api/user/status"
    .done (resp) =>
      if resp.status == "success"
        localStorage.status = JSON.stringify resp.data
        @onChange resp.data
      else
        Api.notify resp

  getStatus: ->
    if localStorage.status?
      JSON.parse localStorage.status
    else
      {}

  dirtyStatus: ->
    delete localStorage.status

  onChange: ->
