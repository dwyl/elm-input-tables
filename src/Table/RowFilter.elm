module Table.RowFilter exposing (filter)

import String exposing (contains, toLower, length)
import MainModel exposing (..)
import Table.Utils exposing (..)


filter : List Row -> List Column -> String -> List Row
filter rows columns searchText =
    let
        allColumnsPassFilterAndSearch row =
            List.any (columnPassesSearch searchText row) columns
                && List.all (columnPassesFilter row) columns
    in
        List.filter allColumnsPassFilterAndSearch rows


columnPassesSearch searchText row column =
    case column.subType of
        DisplayColumn props ->
            containsCi (props.get row.data) searchText

        TextColumn props ->
            containsCi (props.get row.data) searchText

        DropdownColumn props ->
            containsCi (props.get row.data) searchText

        CheckboxColumn props ->
            False


columnPassesFilter row column =
    case column.subType of
        DisplayColumn props ->
            isFilterSubstring row props

        TextColumn props ->
            isFilterSubstring row props

        DropdownColumn props ->
            isFilterSubstring row props

        CheckboxColumn props ->
            case props.filter of
                Nothing ->
                    True

                Just bool ->
                    (props.get row.data) == bool


isFilterSubstring row props =
    containsCi (props.get row.data) props.filter


containsCi subString string =
    (contains (toLower string) (toLower subString))
