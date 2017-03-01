module Table.RowFilter exposing (filter)

import String exposing (contains, toLower, length)


filter rows columns searchText =
    let
        allColumnsPassFilter row =
            List.any (columnPassesSearch row) columns
                && List.all (columnPassesFilter row) columns

        columnPassesSearch row column =
            containsCi (column.getVal row.data) searchText

        columnPassesFilter row column =
            containsCi (column.getVal row.data) column.filterText
    in
        List.filter allColumnsPassFilter rows


containsCi subString string =
    (contains (toLower string) (toLower subString))
