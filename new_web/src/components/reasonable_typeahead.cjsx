React = require 'react'

RB = require 'react-bootstrap'

ListGroup = RB.ListGroup
ListGroupItem = RB.ListGroupItem

Typeahead = (require "react-typeahead").Typeahead

_ = require "underscore"

ReasonableList = React.createClass
  render: ->
    console.log @props
    <ListGroup>
      {_.map @props.options, (option, i) =>
        <ListGroupItem
          onClick={_.partial @props.onOptionSelected, option}
          key={i}>{option}</ListGroupItem>}
    </ListGroup>

ReasonableTypeahead = React.createClass
  bootstrapClasses:
    input: "input form-control"

  onOptionSelectedWrapper: (option) ->
    @refs.type.setState
       entryValue: ''
       selection: null
       selectionIndex: null
       visible: []

    if @props.onOptionSelected
      @props.onOptionSelected option

  render: ->
    <Typeahead ref="type"
      defaultClassNames={false}
      customClasses={@bootstrapClasses}
      customListComponent={@props.customListComponent || ReasonableList}
      maxVisible={@props.maxVisible || 8}
      {...@props}
      onOptionSelected={@onOptionSelectedWrapper}/>

module.exports = ReasonableTypeahead
