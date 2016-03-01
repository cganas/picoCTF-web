React = require 'react'

Api = require '../utils/api'
RB = require "react-bootstrap"

Row = RB.Row
Col = RB.Col
Panel = RB.Panel
Button = RB.Button


download = require "downloadjs"
_ = require 'underscore'


ExportOrganizationStatistics = React.createClass
  propTypes:
    gid: React.PropTypes.string.isRequired
    members: React.PropTypes.array.isRequired
    teachers: React.PropTypes.array.isRequired

  exportProblemCSV: ->
    Api.call "GET", "/api/group/problems/stats"
    .done (resp) =>
      if resp.status == 0
        apiNotify resp
      else
        problems = _.filter resp.data.problems, (problem) -> !problem.disabled
        data = [["Username", "First Name", "Last Name"].concat(_.map(problems, (problem) -> problem.name), ["Total"])]
        teams = @props.teachers.concat @props.members
        _.each teams, ((team) =>
          member = team.members[0]
          teamData = [member.username, member.firstname, member.lastname]
          teamData = teamData.concat _.map problems, ((problem) ->
            solved = _.find team.solved_problems, (solvedProblem) -> solvedProblem.name == problem.name
            return if solved then problem.score else 0
          )
          teamData = teamData.concat [team.score]
          data.push teamData
        )
        csvData = (_.map data, (fields) -> fields.join ",").join "\n"
        download csvData, "#{@props.gid}.csv", "text/csv"

  render: ->
    <Panel>
      <Row>
        <Col xs={4}>
          <h4>Problems solved per team</h4>
        </Col>
        <Col xs={4}>
          <Button onClick={@exportProblemCSV}>Export CSV</Button>
        </Col>
      </Row>
    </Panel>

module.exports = ExportOrganizationStatistics
