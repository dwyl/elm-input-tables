module Table.Model exposing (..)


type alias TableState rowData =
    { columns : List (Column rowData)
    , rows : List (Row rowData)
    , searchText : String
    , showVisibleColumnsUi : Bool
    , sorting : Sorting
    , externalFilter : Row rowData -> Bool
    }


type Sorting
    = NoSorting
    | Asc Int
    | Desc Int


type alias Column rowData =
    { id : Int
    , name : String
    , visible : Bool
    , subType : ColumnSubType rowData
    }


type ColumnSubType rowData
    = DisplayColumn (DisplayColumnProps rowData)
    | TextColumn (TextColumnProps rowData)
    | DropdownColumn (DropdownColumnProps rowData)
    | SubDropdownColumn (SubDropdownColumnProps rowData)
    | CheckboxColumn (CheckboxColumnProps rowData)


type alias DisplayColumnProps rowData =
    { get : rowData -> String
    , filter : String
    }


type alias TextColumnProps rowData =
    { get : rowData -> String
    , set : rowData -> String -> rowData
    , filter : String
    , isTextArea : Bool
    }


type alias DropdownColumnProps rowData =
    { get : rowData -> String
    , set : rowData -> String -> rowData
    , filter : String
    , options : List String
    }


type alias SubDropdownColumnProps rowData =
    { get : rowData -> ( String, Maybe String )
    , set : rowData -> ( String, Maybe String ) -> rowData
    , filter : String
    , options : List SubDropdownOptionProps
    , focussedRowId : Maybe Int
    , focussedOption : Maybe String
    }


type alias SubDropdownOptionProps =
    { parent : String
    , childHeader : Maybe String
    , children : List String
    }


type alias CheckboxColumnProps rowData =
    { get : rowData -> Bool
    , set : rowData -> Bool -> rowData
    , filter : Maybe Bool
    }


type alias Row rowData =
    { id : Int
    , data : rowData
    , checked : Bool
    }
