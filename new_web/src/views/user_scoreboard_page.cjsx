React = require 'react'

History = (require "react-router").History

ShowIf = (require "../utils/react_helper").ShowIf

RB = require 'react-bootstrap'

Glyphicon = RB.Glyphicon
Panel = RB.Panel
Input = RB.Input
Row = RB.Row
Col = RB.Col
Button = RB.Button
Badge = RB.Badge
Grid = RB.Grid

Tabs = RB.Tabs
Tab = RB.Tab
Table = RB.Table

ListGroup = RB.ListGroup
ListGroupItem = RB.ListGroupItem

Pagination = RB.Pagination

ChartJS = require "rc-chartjs"
LineChart = ChartJS.Line


update = require 'react-addons-update'

_ = require 'underscore'

Api = require '../utils/api'

ScoreboardProgressionGraph = React.createClass
  propTypes:
    topTeams: React.PropTypes.array.isRequired

  getInitialState: -> {}

  numSubmissions: -30

  strokeColors: [
    "rgba(156,99,169,1)"
    "rgba(151,187,205,1)"
    "rgba(230,22,22,1)"
    "rgba(22,230,57,1)"
    "rgba(230,22,210,1)"
    "rgba(220,220,220,1)"
    "rgba(204,104,0,1)"
  ]

  fillColors: [
    "rgba(156,99,169,0.2)"
    "rgba(151,187,205,0.2)"
    "rgba(230,22,22,0.2)"
    "rgba(22,230,57,0.2)"
    "rgba(230,22,210,0.2)"
    "rgba(220,220,220,0.2)"
    "rgba(204,104,0,0.2)"
  ]

  render: ->

    if @props.topTeams.length > 0
      getClosestScore = (team, time) ->
        score = 0
        for submission in team.score_progression
          if submission.time <= time
            score = submission.score
          else
            break
        return score

      totalSubmissionsList = _.flatten(_.map @props.topTeams, "score_progression")
      relevantSubmissionsList = _.sortBy(totalSubmissionsList, "time")[@numSubmissions..]

      submissionTimes = _.map relevantSubmissionsList, "time"

      data =
        labels: _.map submissionTimes, (time) ->
          d = new Date(time * 1000)
          "#{d.getHours()}:#{d.getMinutes()} #{d.getMonth()+1}/#{d.getDay()}"

        datasets: []
      data.xLabels = data.labels
      for team, i in @props.topTeams
        data.datasets.push
          label: team.name
          data: _.map submissionTimes, (_.partial getClosestScore, team)
          pointColor: @strokeColors[i % @strokeColors.length]
          strokeColor: @strokeColors[i % @strokeColors.length]
          fillColor: @fillColors[i % @strokeColors.length]

      scoreboardChartSettings =
        scaleShowGridLines: false
        pointDot: false
        bezierCurve: false

      <Row>
        <Col xs={10}>
          <LineChart
            className="center-block"
            data={data}
            options={scoreboardChartSettings}
            style={width: "90%", height: "300px"}
            redraw/>
        </Col>
        <Col xs={2}>
          <ListGroup id="top-scoreboard">
          {@props.topTeams.map (team, i) ->
            <ListGroupItem key={i}>
              <span style={color: data.datasets[i].strokeColor}>{team.name}</span>
              <ShowIf truthy={i == 0}>
                <Glyphicon className="pull-right" glyph="king"/>
              </ShowIf>
            </ListGroupItem>}
          </ListGroup>
        </Col>
      </Row>
    else
      <span/>

Scoreboard = React.createClass
  propTypes:
    teams: React.PropTypes.array.isRequired

  teamsPerPage: 20

  getInitialState: ->
    activePage: 1
    topTeams: []

  handlePageSelect: (e, selectedEvent) ->
    @setState update @state, $set: activePage: selectedEvent.eventKey

  render: ->
    allTeams = @props.teams.map (team, i) ->
      team["position"] = i+1
      team

    teamPages = parseInt (@props.teams.length / @teamsPerPage) + 1

    activeIndex = @state.activePage - 1
    startOfPage = activeIndex * @teamsPerPage
    shownTeams = allTeams.slice startOfPage, startOfPage + @teamsPerPage

    <div>
      <ShowIf truthy={allTeams.length > 1 and @props.active}>
      </ShowIf>
      <Table responsive>
        <thead>
          <tr>
            <th>#</th>
            <th>Team</th>
            <th>Affiliation</th>
            <th>Score</th>
          </tr>
        </thead>
        <tbody>
          {shownTeams.map (team, i) ->
            <tr key={i}>
              <td>{team.position}.</td>
              <td>{team.name}</td>
              <td>{team.affiliation}</td>
              <td>{team.score}</td>
            </tr>}
        </tbody>
      </Table>
      <ShowIf truthy={allTeams.length > @teamsPerPage}>
        <Pagination first next prev last ellipsis
          maxButtons={10}
          className="pull-right"
          items={teamPages}
          activePage={@state.activePage}
          onSelect={@handlePageSelect}/>
      </ShowIf>
    </div>

UserScoreboardPage = React.createClass

  mixins: [History]

  getInitialState: ->
    public: []
    groups: []
    ineligible: []
    topTeams: []

  componentWillMount: ->
    Api.call "GET", "/api/stats/scoreboard"
    .done (resp) =>
      if resp.status == "error"
        Api.notify resp
      else
        @setState resp.data
        @onGroupChange @props.params.group

  onGroupChange: (groupName) ->
    if groupName != "Public" and groupName != "Ineligible"
      group = _.find @state.groups, (currentGroup) -> currentGroup.name == groupName
      if group
        Api.call "GET", "/api/stats/group/score_progression", {gid: group.gid}
        .done (resp) =>
          if resp.status == "success"
            @setState update @state, $set: topTeams: resp.data
          else
            Api.notify resp
    else
      Api.call "GET", "/api/stats/top_teams/score_progression", {eligible: groupName == "Public"}
      .done (resp) =>
        if resp.status == "success"
          @setState update @state, $set: topTeams: resp.data
        else
          Api.notify resp

  onTabSelect: (tab) ->
    @history.push "/scoreboard/#{tab}"
    @onGroupChange tab

  render: ->
    <Grid>
      <ScoreboardProgressionGraph topTeams={@state.topTeams}/>
      <Tabs activeKey={@props.params.group} onSelect={@onTabSelect}>
        <Tab eventKey="Public" title="Public">
          <Scoreboard
            name="Public"
            teams={@state.public}/>
        </Tab>
        {@state.groups.map (group, i) =>
          <Tab key={group.gid} eventKey={group.name} title={group.name}>
            <Scoreboard
              name={group.name}
              teams={group.scoreboard}/>
          </Tab>}
        <ShowIf truthy={@state.ineligible.length > 0}>
          <Tab eventKey="Ineligible" title="Ineligible">
            <Scoreboard
              name="Ineligible"
              teams={@state.ineligible}/>
          </Tab>
        </ShowIf>
      </Tabs>
    </Grid>

module.exports = UserScoreboardPage
