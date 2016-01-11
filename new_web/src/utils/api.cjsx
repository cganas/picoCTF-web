$ = require "jquery"
Noty = require "noty"
Cookies = require "js-cookie"

Api = {}

Api.call = (verb, url, data) ->
  if verb == "POST"
    data.token = Cookies.get "token"
  $.ajax {url: url, type: verb, data: data, cache: false}
  .fail (jqXHR, text) ->
    Api.notify {status: "error", message: "The server is currently down. We will work to fix this error right away."}

Api.notify = (data) ->
    notification =
      type: data.status
      layout: "topRight"
      text: data.message
      timeout: 2000

    Noty(notification)

module.exports = Api
