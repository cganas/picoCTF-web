React = require 'react'

Link = (require "react-router").Link
History = (require "react-router").History

LinkedStateMixin = require 'react-addons-linked-state-mixin'

ShowIf = (require "../utils/react_helper").ShowIf

RB = require 'react-bootstrap'

Panel = RB.Panel
Input = RB.Input
Col = RB.Col
Button = RB.Button
Glyphicon = RB.Glyphicon

Table = RB.Table

_ = require 'underscore'

Api = require "../utils/api"

update = require 'react-addons-update'

OrganizationManagementForm = React.createClass
  mixins: [History]

  getInitialState: ->
    groups: []

  componentWillMount: ->
    Api.call "GET", "/api/group/list"
    .done (resp) =>
      if resp.status == "success"
        @setState groups: resp.data
      else
        Api.notify resp

  render: ->
    console.log @state
    <Panel header="Organization Management">
      <Table>
        <thead>
          <tr>
            <th>Organization Name</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
        {@state.groups.map (group, i) =>
          <tr key={i}>
            <td>{group.name} ({group.owner})</td>
            <td>
              <ShowIf truthy={@props.status.username == group.owner}>
                <Glyphicon glyph="remove"/>
              </ShowIf>
            </td>
          </tr>}
        </tbody>
      </Table>

    </Panel>

module.exports = OrganizationManagementForm
