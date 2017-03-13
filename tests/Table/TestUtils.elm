module Table.TestUtils exposing (..)

import Table.Model exposing (..)


type alias TestRowData =
    { boolProp : Bool
    , title : String
    , subCategory : ( String, Maybe String )
    }


makeRow : String -> Bool -> ( String, Maybe String ) -> Int -> Row TestRowData
makeRow =
    makeRowInternal False


makeCheckedRow : String -> Bool -> ( String, Maybe String ) -> Int -> Row TestRowData
makeCheckedRow =
    makeRowInternal True


makeRowInternal : Bool -> String -> Bool -> ( String, Maybe String ) -> Int -> Row TestRowData
makeRowInternal checked title boolProp subCategory id =
    { id = id
    , data =
        { title = title
        , boolProp = boolProp
        , subCategory = subCategory
        }
    , checked = checked
    }


testTableState : TableState TestRowData
testTableState =
    rowsToTableState initialRows


rowsToTableState : List (Row TestRowData) -> TableState TestRowData
rowsToTableState rows =
    { columns =
        [ titleColumn
        , subCategoryColumn
        , boolColumn
        ]
    , rows = rows
    , searchText = ""
    , showVisibleColumnsUi = False
    , sorting = NoSorting
    , externalFilter = (\r -> True)
    , pageSize = Just 3
    , currentPage = 1
    }


initialRows : List (Row TestRowData)
initialRows =
    List.range 1 4
        |> List.map (makeRow "test title" True ( "no children", Nothing ))


titleColumn : Column TestRowData
titleColumn =
    Column 1 "title" True (TextColumn (TextColumnProps .title (\d v -> { d | title = v }) "" False))


subCategoryColumn : Column TestRowData
subCategoryColumn =
    Column 2
        "sub category"
        True
        (SubDropdownColumn
            (SubDropdownColumnProps
                .subCategory
                (\d ( val, sub ) -> { d | subCategory = ( val, sub ) })
                ""
                [ { parent = "no children", childHeader = Nothing, children = [] }
                , { parent = "has children", childHeader = Just "To: ", children = [ "child 1", "child 2" ] }
                ]
                Nothing
                Nothing
            )
        )


boolColumn : Column TestRowData
boolColumn =
    Column 3 "bool prop" True (CheckboxColumn (CheckboxColumnProps .boolProp (\d _ -> { d | boolProp = not d.boolProp }) Nothing))
