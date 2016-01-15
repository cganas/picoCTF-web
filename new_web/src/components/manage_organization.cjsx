React = require 'react'

$ = require 'jquery'
_ = require 'underscore'

ChartJS = require "react-chartjs"
RadarChart = ChartJS.Radar

update = require 'react-addons-update'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

Api = require '../utils/api'

RB = require "react-bootstrap"

Input = RB.Input
Row = RB.Row
Col = RB.Col
Button = RB.Button
ButtonGroup = RB.ButtonGroup
Panel = RB.Panel
ListGroup = RB.ListGroup
ListGroupItem = RB.ListGroupItem
Glyphicon = RB.Glyphicon
Pagination = RB.Pagination


Table = RB.Table
Tabs = RB.Tabs
Tab = RB.Tab

ShowIf = (require "../utils/react_helper").ShowIf

ManageOrganization = React.createClass
  getInitialState: ->
    members: []
    teachers: []
    settings:
      email_filter: []
      hidden: false
    currentTeamName: null

  onGroupChange: ->
    Api.call "GET", "/api/group/settings", {gid: @props.gid}
    .done (resp) =>
      if resp.status == "success"
        @setState update @state, $merge: settings: resp.data.settings
      else
        Api.notify resp

    Api.call "GET", "/api/group/member_information", {gid: @props.gid}
    .done (resp) =>
      if resp.status == "success"
        @setState update @state, $set: members: resp.data
      else
        Api.notify resp

    Api.call "GET", "/api/group/teacher_information", {gid: @props.gid}
    .done (resp) =>
      if resp.status == "success"
        @setState update @state, $set: teachers: resp.data
      else
        Api.notify resp

  pushUpdates: (modifier) ->
    data = @state

    if modifier
      data.settings = modifier data.settings

    Api.call "POST", "/api/group/settings", {gid: @props.gid, settings: JSON.stringify data.settings}
    .done (resp) =>
      Api.notify resp
      @onGroupChange()

  componentWillMount: ->
    @onGroupChange()

  createInformationView: (sortedTeams, team) ->

    average = (data) -> (_.reduce(data, (a, b) -> a+b)/data.length).toFixed 2

    sortedScores = _.map sortedTeams, "score"
    minScore = _.first sortedScores
    maxScore = _.last sortedScores
    averageScore = parseInt average(sortedScores)

    std = _.reduce(_.map(sortedScores, (score) ->
      Math.pow (score - averageScore), 2), (runningTotal, score) ->
      runningTotal + score)
    stdDeviation = Math.pow((std / sortedScores.length), 1/2).toFixed 2

    categoryData = _.map sortedTeams, (team) ->
      relevantProblems = _.filter team.solved_problems, (problem) -> !problem.disabled
      _.groupBy relevantProblems, "category"

    teamAverages = _.map categoryData, (teamProblems) ->
      _.mapObject teamProblems, (problems) ->
        problemScores = _.map problems, "score"
        _.reduce problemScores, ((totalScore, score) -> totalScore + score), 0

    averageAggregator = (total, categories) ->
      _.each categories, (score, name) ->
        if !(_.has total, name)
            total[name] = []
        total[name].push score
      total

    averageByCategory = _.mapObject (_.reduce teamAverages, averageAggregator, {}), average

    sortedKeys = _.sortBy _.keys(averageByCategory)
    sortedValues = _.map sortedKeys, (key) -> averageByCategory[key]

    data =
      labels: sortedKeys
      datasets: [
        label: "Class Averages"
        fillColor: "rgba(220,220,220,0.2)"
        strokeColor: "rgba(220,220,220,1)"
        pointColor: "rgba(220,220,220,1)"
        pointStrokeColor: "#fff"
        pointHighlightFill: "#fff"
        pointHighlightStroke: "rgba(220,220,220,1)"
        data: sortedValues
      ]
    data.xLabels = data.labels

    generateRadarData = (team) ->
      teamCategoryData = _.mapObject _.groupBy(team.solved_problems, "category"), (problems) ->
        problemScores = _.map problems, "score"
        _.reduce problemScores, (totalScore, score) -> totalScore + score

      teamValues = _.map sortedKeys, (key) ->
        if _.has(teamCategoryData, key)
          teamCategoryData[key]
        else 0

      teamData =
        label: team.team_name,
        fillColor: "rgba(151,187,205,0.2)"
        strokeColor: "rgba(151,187,205,1)"
        pointColor: "rgba(151,187,205,1)"
        pointStrokeColor: "#fff"
        pointHighlightFill: "#fff"
        pointHighlightStroke: "rgba(151,187,205,1)"
        data: teamValues
      averageData = $.extend true, {}, data
      averageData.datasets.push teamData

      averageData

    <div className="text-center">
      <Panel>
        <Col xs={3}>
          <span>Min: {minScore}</span>
        </Col>
        <Col xs={3}>
          <span>Max: {maxScore}</span>
        </Col>
        <Col xs={3}>
          <span>Avg: {averageScore}</span>
        </Col>
        <Col xs={3}>
          <span>You: <strong>{team.score}</strong></span>
        </Col>
      </Panel>
      <div>
        <h4>{team.team_name} Performance vs. Organization Average</h4>
        <RadarChart
          width="400px"
          height="400px"
          data={generateRadarData team}
          redraw/>
      </div>
      <ShowIf truthy={team.flagged_submissions.length > 0}>
        <Panel bsStyle="warning" header="Flagged Submissions">
          <Table responsive>
            <thead>
              <tr>
                <th>Problem</th>
                <th>Flag</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
            {team.flagged_submissions.map (submission, i) ->
              <tr key={i}>
                <td>{submission.problem_name}</td>
                <td>{submission.key}</td>
                <td>{new Date(submission.timestamp["$date"]).toUTCString()}</td>
              </tr>}
            </tbody>
          </Table>
        </Panel>
      </ShowIf>
      <ShowIf truthy={team.solved_problems.length > 0}>
        <Panel header="Solved Problems List">
          <div className="solved-problems-table">
            <Table responsive>
              <thead>
                <tr>
                  <th>Problem</th>
                  <th>Score</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
              {team.solved_problems.map (problem, i) ->
                <tr key={i}>
                  <td>{problem.name}</td>
                  <td>{problem.score}</td>
                  <td>{new Date(problem.solve_time["$date"]).toUTCString()}</td>
                </tr>}
              </tbody>
            </Table>
          </div>
        </Panel>
      </ShowIf>
    </div>

  render: ->

    allTeams = _.union @state.teachers, @state.members
    sortedTeams = _.sortBy allTeams, "score"
    currentTeam = _.find allTeams, (team) => team.team_name == @state.currentTeamName

    if not @state.currentTeamName
      currentTeam = _.first allTeams

    <Tabs defaultActiveKey={1}>
      <Tab style={paddingTop: 10} eventKey={1} title="User Management">
        <Col xs={6}>
          <MemberManagement
            gid={@props.gid}
            members={@state.members}
            teachers={@state.teachers}
            onExamine={(teamName) => @setState update @state, $set: currentTeamName: teamName}
            currentUser={@props.userStatus}
            onGroupChange={@onGroupChange}/>
        </Col>
        <Col xs={6}>
          {if currentTeam then @createInformationView(sortedTeams, currentTeam) else "Not"}
        </Col>
      </Tab>
      <Tab eventKey={2} title="Group Management">
        <GroupOptions pushUpdates={@pushUpdates} settings={@state.settings} gid={@props.gid}/>
        <GroupEmailWhitelist emails={@state.settings.email_filter} pushUpdates={@pushUpdates} gid={@props.gid}/>
      </Tab>
    </Tabs>

GroupOptions = React.createClass
  propTypes:
    settings: React.PropTypes.object.isRequired
    pushUpdates: React.PropTypes.func.isRequired
    gid: React.PropTypes.string.isRequired

  promptGroupHide: ->
    window.confirmDialog "Hiding your group from the scoreboard is an irrevocable change. You won't be able to change this later.", "Hidden Group Change",
    "Okay", "Cancel", () =>
      @props.pushUpdates ((data) -> update data, hidden: $set: true), () -> false

  render: ->
    <div>
      <Panel>
        <form>
          <ShowIf truthy={@props.settings.hidden}>
            <p>This group is <b>hidden</b> from the general scoreboard.</p>
          </ShowIf>
          <ShowIf truthy={!@props.settings.hidden}>
            <p>
              This group is <b>visible</b> on the scoreboard.
              Click <a href="#" onClick={@promptGroupHide}>here</a> to hide it.
            </p>
          </ShowIf>
        </form>
      </Panel>
    </div>

EmailWhitelistItem = React.createClass
  propTypes:
    email: React.PropTypes.string.isRequired
    pushUpdates: React.PropTypes.func.isRequired

  render: ->
    removeEmail = @props.pushUpdates.bind null, (data) =>
      update data, email_filter: $apply: _.partial _.without, _, @props.email

    <ListGroupItem>
      *@{@props.email}
      <span className="pull-right"><Glyphicon glyph="remove" onClick={removeEmail}/></span>
    </ListGroupItem>

GroupEmailWhitelist = React.createClass
  mixins: [LinkedStateMixin]

  getInitialState: -> {}

  propTypes:
    pushUpdates: React.PropTypes.func.isRequired
    emails: React.PropTypes.array.isRequired
    gid: React.PropTypes.string.isRequired

  addEmailDomain: (e) ->
    # It would probably make more sense to this kind of validation server side.
    # However, it can't cause any real issue being here.

    e.preventDefault()

    if _.indexOf(@props.emails, @state.emailDomain) != -1
      Api.notify {status: "error", message: "This email domain has already been whitelisted."}
    else if _.indexOf(@state.emailDomain, "@") != -1
      Api.notify {status: "error", message: "You should not include '@'. I want the email domain that follows '@'."}
    else if _.indexOf(@state.emailDomain, ".") == -1
        Api.notify {status: "error", message: "Your email domain did not include a '.' as I expected. Please make sure this is an email domain."}
    else
      @props.pushUpdates (data) =>
        #Fine because @setState won't affect the next line
        @setState update @state, $set: emailDomain: ""
        update data, email_filter: $push: [@state.emailDomain]

  createItemDisplay: ->
    <ListGroup>
      {@props.emails.map (email, i) =>
        <EmailWhitelistItem key={i} email={email} pushUpdates={@props.pushUpdates}/>}
    </ListGroup>

  render: ->
    emptyItemDisplay =
      <p>The whitelist is current empty. All emails will be accepted during registration.</p>

    <div>
      <h4>Email Domain Whitelist</h4>
        <Panel>
          <form onSubmit={@addEmailDomain}>
            <Input type="text" addonBefore="@ Domain" valueLink={@linkState "emailDomain"}/>
            {if @props.emails.length > 0 then @createItemDisplay() else emptyItemDisplay}
          </form>
        </Panel>
    </div>

MemberManagement = React.createClass
  membersPerPage: 20

  getInitialState: ->
    activePage: 1

  handlePageSelect: (e, selectedEvent) ->
    @setState update @state, $set: activePage: selectedEvent.eventKey

  render: ->
    allMembers = update @props.teachers, $push: @props.members
    allMembers = _.filter allMembers, (member) => @props.currentUser["tid"] != member["tid"]

    memberPages = parseInt (allMembers.length / @membersPerPage) + 1

    activeIndex = @state.activePage - 1
    startOfPage = activeIndex * @membersPerPage
    shownMembers = allMembers.slice startOfPage, startOfPage + @membersPerPage

    <div>
      <MemberInvitePanel {...@props}/>
      <ListGroup>
        {shownMembers.map (member, i) =>
          <MemberManagementItem
            key={@props.gid+i}
            {...member}
            {...@props}/>}
      </ListGroup>
      <ShowIf truthy={allMembers.length > @membersPerPage}>
        <Pagination first next prev last ellipsis
          maxButtons={8}
          className="pull-right"
          items={memberPages}
          activePage={@state.activePage}
          onSelect={@handlePageSelect}/>
      </ShowIf>
    </div>

MemberManagementItem = React.createClass
  removeTeam: ->
    Api.call "POST", "/api/group/teacher/leave", {gid: @props.gid, tid: @props.tid}
    .done (resp) =>
      Api.notify resp
      @props.onGroupChange()

  switchUserRole: (tid, role) ->
    Api.call "POST", "/api/group/teacher/role_switch", {gid: @props.gid, tid: tid, role: role}
    .done (resp) =>
      Api.notify resp
      @props.onGroupChange()

  render: ->
    <ListGroupItem>
      <Row>
        <Col xs={6}>
          <ShowIf truthy={@props.teacher}>
            <Button bsStyle="success" className="btn-sq">
              <p className="text-center">Coach</p>
            </Button>
          </ShowIf>
          <ShowIf truthy={!@props.teacher}>
            <Button bsStyle="primary" className="btn-sq">
              <p className="text-center">User</p>
            </Button>
          </ShowIf>
          <span style={paddingLeft: 10}>
            <a onClick={_.partial @props.onExamine, @props.team_name}>{@props.team_name}</a> <strong>{@props.score}</strong>
          </span>
        </Col>
        <Col xs={6}>
          <ButtonGroup className="pull-right">
            <ShowIf truthy={@props.teacher}>
              <Button onClick={@switchUserRole.bind(null, @props.tid, "member")}>Make Member</Button>
            </ShowIf>
            <ShowIf truthy={!@props.teacher}>
              <Button onClick={@switchUserRole.bind(null, @props.tid, "teacher")}>Make Coach</Button>
            </ShowIf>
            <Glyphicon style={paddingLeft: 20} glyph="remove" onClick={@removeTeam}/>
          </ButtonGroup>
        </Col>
      </Row>
    </ListGroupItem>

MemberInvitePanel = React.createClass
  mixins: [LinkedStateMixin]

  propTypes:
    gid: React.PropTypes.string.isRequired

  getInitialState: ->
    role: "member"

  inviteUser: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/group/invite", {gid: @props.gid, email: @state.email, role: @state.role}
    .done (resp) =>
      Api.notify resp
      @setState update @state, $set: email: ""
      @props.onGroupChange()

  render: ->
    <Panel>
      <form onSubmit={@inviteUser}>
        <Col xs={8}>
          <Input type="email" label="E-mail" valueLink={@linkState "email"}/>
        </Col>
        <Col xs={4}>
          <Input type="select" label="Role" placeholder="Member" valueLink={@linkState "role"}>
            <option value="member">Member</option>
            <option value="teacher">Teacher</option>
          </Input>
        </Col>
        <Col xs={4}>
          <Button onClick={@inviteUser}>Invite User</Button>
        </Col>
      </form>
    </Panel>

module.exports = ManageOrganization
