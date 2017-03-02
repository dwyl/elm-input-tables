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
    case column.config of
        DisplayColumn config ->
            containsCi (config.get row.data) searchText

        TextColumn config ->
            containsCi (config.get row.data) searchText

        DropdownColumn config ->
            containsCi (config.get row.data) searchText

        CheckboxColumn config ->
            False


columnPassesFilter row column =
    case column.config of
        DisplayColumn config ->
            isFilterSubstring row config

        TextColumn config ->
            isFilterSubstring row config

        DropdownColumn config ->
            isFilterSubstring row config

        CheckboxColumn config ->
            case config.filter of
                Nothing ->
                    True

                Just bool ->
                    (config.get row.data) == bool


isFilterSubstring row config =
    containsCi (config.get row.data) config.filter


containsCi subString string =
    (contains (toLower string) (toLower subString))
