module Table.UpdateTest exposing (all)

import Test exposing (..)
import Expect
import Table.Messages exposing (..)
import Table.Model exposing (..)
import Table.Update exposing (update)
import Table.TestUtils exposing (..)


all : Test
all =
    describe "Update.update"
        [ test "SetCellValue message should set the cell with that id to the given value" <|
            \() ->
                let
                    newTableState =
                        update
                            (SetCellValue (\d v -> { d | title = v }) 2 "new title value")
                            testTableState

                    expectedRows =
                        [ makeRow "test title" True ( "no children", Nothing ) 1
                        , makeRow "new title value" True ( "no children", Nothing ) 2
                        , makeRow "test title" True ( "no children", Nothing ) 3
                        , makeRow "test title" True ( "no children", Nothing ) 4
                        ]
                in
                    Expect.equal newTableState.rows expectedRows
        , test """ToggleCellDropdown message should set the focussedRowId to the
         row that with the event listener and the focussedOption to Nothing""" <|
            \() ->
                let
                    newTableState =
                        update
                            (ToggleCellDropdown 3 2)
                            testTableState

                    focussedRowIds =
                        newTableState
                            |> .columns
                            |> List.map .subType
                            |> List.map getFocussedRowId

                    getFocussedRowId subType =
                        case subType of
                            SubDropdownColumn props ->
                                props.focussedRowId

                            _ ->
                                Nothing

                    expectedFocussedRowIds =
                        [ Nothing, Just 3, Nothing ]
                in
                    Expect.equal focussedRowIds expectedFocussedRowIds
        , test """ToggleVisibleRowsCheckboxes should set all visible rows to checked if
           some of them are not checked""" <|
            \() ->
                let
                    newTableState =
                        update
                            (ToggleVisibleRowsCheckboxes [ row1, row2 ])
                            testTableState

                    row1 =
                        makeCheckedRow "test title" True ( "no children", Nothing ) 1

                    row2 =
                        makeRow "test title" True ( "no children", Nothing ) 2

                    expectedRows =
                        [ makeCheckedRow "test title" True ( "no children", Nothing ) 1
                        , makeCheckedRow "test title" True ( "no children", Nothing ) 2
                        , makeRow "test title" True ( "no children", Nothing ) 3
                        , makeRow "test title" True ( "no children", Nothing ) 4
                        ]
                in
                    Expect.equal newTableState.rows expectedRows
        , test """ToggleVisibleRowsCheckboxes should set all visible rows to unchecked if
           all of them are checked""" <|
            \() ->
                let
                    newTableState =
                        update
                            (ToggleVisibleRowsCheckboxes [ row1, row2 ])
                            testTableState

                    row1 =
                        makeCheckedRow "test title" True ( "no children", Nothing ) 1

                    row2 =
                        makeCheckedRow "test title" True ( "no children", Nothing ) 2

                    expectedRows =
                        [ makeRow "test title" True ( "no children", Nothing ) 1
                        , makeRow "test title" True ( "no children", Nothing ) 2
                        , makeRow "test title" True ( "no children", Nothing ) 3
                        , makeRow "test title" True ( "no children", Nothing ) 4
                        ]
                in
                    Expect.equal newTableState.rows expectedRows
        , test """SortRows message with a string column should sort the rows alphabetically
           by the values in that column.""" <|
            \() ->
                let
                    unsortedRows =
                        [ makeRow "zebra" True ( "has children", Just "child 2" ) 1
                        , makeRow "kilo" True ( "has children", Just "child 1" ) 2
                        , makeRow "yellow" False ( "no children", Nothing ) 4
                        , makeRow "alpha" False ( "no children", Nothing ) 3
                        ]

                    tableStateSortedOnTitle =
                        update
                            (SortRows titleColumn)
                            (rowsToTableState unsortedRows)

                    expectedSortedOnTitle =
                        [ makeRow "alpha" False ( "no children", Nothing ) 3
                        , makeRow "kilo" True ( "has children", Just "child 1" ) 2
                        , makeRow "yellow" False ( "no children", Nothing ) 4
                        , makeRow "zebra" True ( "has children", Just "child 2" ) 1
                        ]
                in
                    Expect.equal tableStateSortedOnTitle.rows expectedSortedOnTitle
        , test """SortRows message with a SubDropdownColumn column should sort the rows alphabetically
           by the values in that column, using subchoice as a secondary comparator.
           Any equal columns should use the id as a final comparator""" <|
            \() ->
                let
                    unsortedRows =
                        [ makeRow "zebra" True ( "has children", Just "child 2" ) 1
                        , makeRow "kilo" True ( "has children", Just "child 1" ) 2
                        , makeRow "yellow" False ( "no children", Nothing ) 4
                        , makeRow "alpha" False ( "no children", Nothing ) 3
                        ]

                    tableStateSortedOnSubCategory =
                        update
                            (SortRows subCategoryColumn)
                            (rowsToTableState unsortedRows)

                    expectedSortedOnSubCategory =
                        [ makeRow "kilo" True ( "has children", Just "child 1" ) 2
                        , makeRow "zebra" True ( "has children", Just "child 2" ) 1
                        , makeRow "alpha" False ( "no children", Nothing ) 3
                        , makeRow "yellow" False ( "no children", Nothing ) 4
                        ]
                in
                    Expect.equal tableStateSortedOnSubCategory.rows expectedSortedOnSubCategory
        ]
