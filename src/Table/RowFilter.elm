module Table.RowFilter exposing (run)

import String exposing (contains, toLower, length)
import Table.Model exposing (..)


run : List (Row rowData) -> List (Column rowData) -> String -> (Row rowData -> Bool) -> List (Row rowData)
run rows columns searchText externalFilter =
    let
        allColumnsPassFilterAndSearch row =
            List.any (columnPassesSearch searchText row) columns
                && List.all (columnPassesFilter row) columns
    in
        rows
            |> List.filter externalFilter
            |> List.filter allColumnsPassFilterAndSearch


columnPassesSearch : String -> Row rowData -> Column rowData -> Bool
columnPassesSearch searchText row column =
    case column.subType of
        DisplayColumn props ->
            containsCi (props.get row.data) searchText

        TextColumn props ->
            containsCi (props.get row.data) searchText

        DropdownColumn props ->
            containsCi (props.get row.data) searchText

        SubDropdownColumn props ->
            let
                ( choice, subChoice ) =
                    props.get row.data
            in
                containsCi choice searchText
                    || containsCi (Maybe.withDefault "" subChoice) searchText

        CheckboxColumn props ->
            False


columnPassesFilter : Row rowData -> Column rowData -> Bool
columnPassesFilter row column =
    case column.subType of
        DisplayColumn props ->
            isFilterSubstring row props

        TextColumn props ->
            isFilterSubstring row props

        DropdownColumn props ->
            isFilterSubstring row props

        SubDropdownColumn props ->
            let
                ( choice, subChoice ) =
                    props.get row.data
            in
                containsCi choice props.filter
                    || containsCi (Maybe.withDefault "" subChoice) props.filter

        CheckboxColumn props ->
            case props.filter of
                Nothing ->
                    True

                Just bool ->
                    (props.get row.data) == bool


isFilterSubstring : Row rowData -> { a | filter : String, get : rowData -> String } -> Bool
isFilterSubstring row props =
    containsCi (props.get row.data) props.filter


containsCi : String -> String -> Bool
containsCi subString string =
    (contains (toLower string) (toLower subString))
