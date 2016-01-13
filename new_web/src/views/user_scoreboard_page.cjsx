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
Grid = RB.Grid

Tabs = RB.Tabs
Tab = RB.Tab
Table = RB.Table

Pagination = RB.Pagination

ChartJS = require "rc-chartjs"

LineChart = ChartJS.Line

console.log ChartJS, LineChart, "asd"

update = require 'react-addons-update'

_ = require 'underscore'

Api = require '../utils/api'

ScoreboardProgressionGraph = React.createClass
  propTypes:
    topTeams: React.PropTypes.array.isRequired

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
          if submission.time < time
            score = submission.score
          else
            break
        return score

      totalSubmissionsList = _.flatten(_.map @props.topTeams, "score_progression")
      relevantSubmissionsList = _.sortBy(totalSubmissionsList, "time")[-15...]

      submissionTimes = _.map relevantSubmissionsList, "time"

      data =
        labels: _.map submissionTimes, (time) ->
          d = new Date(time)
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

      console.log data
      scoreboardChartSettings =
        pointHitDetectionRadius: 5
        pointDotRadius: 1
        scaleShowGridLines: false
        pointDot: false
        bezierCurve: false
        legendTemplate : "<div class=\"row\">
                            <% for (var i=0; i<datasets.length; i++){%>
                              <span style=\"color:<%=datasets[i].strokeColor%>\" class=\"pad glyphicon glyphicon-user\" aria-hidden=\"true\"></span>
                              <%if(datasets[i].label){%>
                                <%=datasets[i].label%>
                              <%}%>
                            <%}%>
                          </div>"

      <LineChart
        className="center-block"
        data={data}
        options={scoreboardChartSettings}
        style={width: "90%", height: "20%"}/>
    else
      <span/>

Scoreboard = React.createClass
  propTypes:
    teams: React.PropTypes.array.isRequired

  teamsPerPage: 20

  getInitialState: ->
    activePage: 1
    topTeams: []

  componentWillMount: ->
    Api.call "GET", "/api/stats/top_teams/score_progression"
    .done (resp) =>
      if resp.status == "success"
        @setState update @state, $set: topTeams: resp.data
      else
        Api.notify resp

  handlePageSelect: (e, selectedEvent) ->
    @setState update @state, $set: activePage: selectedEvent.eventKey

  render: ->
    console.log @state
    allTeams = @props.teams.map (team, i) ->
      team["position"] = i+1
      team

    teamPages = parseInt (@props.teams.length / @teamsPerPage) + 1

    activeIndex = @state.activePage - 1
    startOfPage = activeIndex * @teamsPerPage
    shownTeams = allTeams.slice startOfPage, startOfPage + @teamsPerPage

    <div>
      <ShowIf truthy={allTeams.length > 1}>
        <ScoreboardProgressionGraph topTeams={@state.topTeams}/>
      </ShowIf>
      <Table responsive>
        <thead>
          <tr>
            <th>#.</th>
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

  componentWillMount: ->
    Api.call "GET", "/api/stats/scoreboard"
    .done (resp) =>
      if resp.status == "error"
        Api.notify resp
      else
        @setState resp.data

  onTabSelect: (tab) ->
    @history.push "/scoreboard/#{tab}"

  render: ->
    console.log @state, "bb"
    <Grid>
      <Tabs activeKey={@props.params.group} onSelect={@onTabSelect}>
        <Tab eventKey="public" title="Public">
          <Scoreboard name="Public" teams={@state.public}/>
        </Tab>
        {@state.groups.map (group, i) ->
          <Tab key={group.gid} eventKey={group.name} title={group.name}>
            <Scoreboard name={group.name} teams={group.scoreboard}/>
          </Tab>}
      </Tabs>
    </Grid>

module.exports = UserScoreboardPage
