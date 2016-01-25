React = require 'react'

RB = require 'react-bootstrap'

Glyphicon = RB.Glyphicon

ListGroup = RB.ListGroup
ListGroupItem = RB.ListGroupItem

Panel = RB.Panel

Typeahead = (require "react-typeahead").Typeahead

_ = require "underscore"

ReasonableList = React.createClass
  render: ->
    if @props.options.length > 0
      <ListGroup>
        {_.map @props.options, (option, i) =>
          <ListGroupItem
            onClick={_.partial @props.onOptionSelected, option}
            key={i}>{option}</ListGroupItem>}
      </ListGroup>
    else
      <Panel>No results found.</Panel>

ReasonableTypeahead = React.createClass
  bootstrapClasses:
    input: "input form-control"

  onOptionSelectedWrapper: (option) ->
    if @props.clear
      @refs.type.setState
        entryValue: ''
        selection: null
        selectionIndex: null
        visible: []

    if @props.onOptionSelected
      @props.onOptionSelected option

  clearOnFocus: ->
    @refs.type.setState
      entryValue: ''
      selection: null
      selectionIndex: null
      visible: []

  render: ->
    <Typeahead ref="type"
      defaultClassNames={false}
      placeholder={@props.placeholder || "Search..."}
      customClasses={@bootstrapClasses}
      customListComponent={@props.customListComponent || ReasonableList}
      maxVisible={@props.maxVisible || 8}
      onFocus={@props.onFocus || @clearOnFocus}
      {...@props}
      onOptionSelected={@onOptionSelectedWrapper}/>

module.exports = ReasonableTypeahead
