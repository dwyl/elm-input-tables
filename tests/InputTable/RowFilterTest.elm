module InputTable.RowFilterTest exposing (all)

import Test exposing (..)
import Expect
import InputTable.RowFilter as RowFilter
import InputTable.Model exposing (..)
import InputTable.TestUtils as TestUtils


all : Test
all =
    describe "RowFilter.run"
        [ test "should filter rows that do not pass a text column filter" <|
            \() ->
                let
                    rows =
                        [ TestUtils.makeRow "test title 1" True ( "no children", Nothing ) 1
                        , TestUtils.makeRow "test title 2" True ( "no children", Nothing ) 2
                        , TestUtils.makeRow "test title 3" True ( "no children", Nothing ) 3
                        ]

                    columns =
                        [ makeTitleColumn "title 1"
                        , makeSubCategoryColumn ""
                        ]

                    expectedResult =
                        [ TestUtils.makeRow "test title 1" True ( "no children", Nothing ) 1 ]
                in
                    Expect.equal (RowFilter.run rows columns "" (\r -> True)) expectedResult
        , test "should filter rows that do not pass a boolean column filter" <|
            \() ->
                let
                    rows =
                        [ TestUtils.makeRow "test title 1" True ( "no children", Nothing ) 1
                        , TestUtils.makeRow "test title 2" True ( "no children", Nothing ) 2
                        , TestUtils.makeRow "test title 3" False ( "no children", Nothing ) 3
                        ]

                    columns =
                        [ makeTitleColumn ""
                        , makeSubCategoryColumn ""
                        , makeBoolColumn (Just True)
                        ]

                    expectedResult =
                        [ TestUtils.makeRow "test title 1" True ( "no children", Nothing ) 1
                        , TestUtils.makeRow "test title 2" True ( "no children", Nothing ) 2
                        ]
                in
                    Expect.equal (RowFilter.run rows columns "" (\r -> True)) expectedResult
        , test "should filter rows that do not pass the search text" <|
            \() ->
                let
                    rows =
                        [ TestUtils.makeRow "test title 1" True ( "no children", Nothing ) 1
                        , TestUtils.makeRow "test title 2" True ( "no children", Nothing ) 2
                        , TestUtils.makeRow "test title 3" True ( "no children", Nothing ) 3
                        ]

                    columns =
                        [ makeTitleColumn ""
                        , makeSubCategoryColumn ""
                        ]

                    expectedResult =
                        [ TestUtils.makeRow "test title 3" True ( "no children", Nothing ) 3 ]
                in
                    Expect.equal (RowFilter.run rows columns "title 3" (\r -> True)) expectedResult
        , test "should filter rows that do not pass the search text and filter columns combined" <|
            \() ->
                let
                    rows =
                        [ TestUtils.makeRow "test title a 1" True ( "no children", Nothing ) 1
                        , TestUtils.makeRow "test title a 2" True ( "has children", Just "child 1" ) 2
                        , TestUtils.makeRow "test title 3" True ( "has children", Just "child 1" ) 3
                        ]

                    columns =
                        [ makeTitleColumn "test title a"
                        , makeSubCategoryColumn ""
                        ]

                    expectedResult =
                        [ TestUtils.makeRow "test title a 2" True ( "has children", Just "child 1" ) 2 ]
                in
                    Expect.equal (RowFilter.run rows columns "ild 1" (\r -> True)) expectedResult
        ]


makeTitleColumn : String -> Column TestUtils.TestRowData
makeTitleColumn filter =
    Column 1 "title" True (TextColumn (TextColumnProps .title (\d v -> { d | title = v }) filter False))


makeSubCategoryColumn : String -> Column TestUtils.TestRowData
makeSubCategoryColumn filter =
    Column 2
        "sub category"
        True
        (SubDropdownColumn
            (SubDropdownColumnProps
                .subCategory
                (\d ( val, sub ) -> { d | subCategory = ( val, sub ) })
                filter
                [ { parent = "no children", childHeader = Nothing, children = [] }
                , { parent = "has children", childHeader = Just "To: ", children = [ "child 1", "child 2" ] }
                ]
                Nothing
                Nothing
            )
        )


makeBoolColumn : Maybe Bool -> Column TestUtils.TestRowData
makeBoolColumn filter =
    Column 3 "bool prop" True (CheckboxColumn (CheckboxColumnProps .boolProp (\d _ -> { d | boolProp = not d.boolProp }) filter))
