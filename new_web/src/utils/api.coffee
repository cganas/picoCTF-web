$ = require "jquery"
Noty = require "noty"

Api = {}

Api.call = (verb, url, data) ->
  #hack
  url = "http://192.168.2.2#{url}"
  $.ajax {url: url, type: verb, data: data, cache: false}
  .fail (jqXHR, text) ->
    Api.notify "The server is currently down. We will work to fix this error right away.", "error"

Api.notify = (data) ->
    notification =
      type: data.status
      layout: "topRight"
      text: "The server says: "+data.message
      timeout: 1000

    Noty(notification)

module.exports = Api
