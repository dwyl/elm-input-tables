module Table.TestUtils exposing (makeRow, TestRowData)

import Table.Model exposing (Row)


type alias TestRowData =
    { boolProp : Bool
    , title : String
    , subCategory : ( String, Maybe String )
    }


makeRow : Int -> String -> Bool -> ( String, Maybe String ) -> Row TestRowData
makeRow id title boolProp subCategory =
    { id = id
    , data =
        { title = title
        , boolProp = boolProp
        , subCategory = subCategory
        }
    , checked = False
    }
