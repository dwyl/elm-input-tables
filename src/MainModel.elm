module MainModel exposing (..)


type alias Model =
    { columns : List Column
    , rows : List Row
    , searchText : String
    , showVisibleColumnsUi : Bool
    , sorting : Sorting
    }


type Sorting
    = NoSorting
    | Asc Int
    | Desc Int


type alias Column =
    { id : Int
    , name : String
    , visible : Bool
    , subType : ColumnSubType
    }


type ColumnSubType
    = DisplayColumn DisplayColumnProps
    | TextColumn TextColumnProps
    | DropdownColumn DropdownColumnProps
    | CheckboxColumn CheckboxColumnProps


type alias DisplayColumnProps =
    { get : RowData -> String
    , filter : String
    }


type alias TextColumnProps =
    { get : RowData -> String
    , set : RowData -> String -> RowData
    , filter : String
    , isTextArea : Bool
    }


type alias DropdownColumnProps =
    { get : RowData -> String
    , set : RowData -> String -> RowData
    , filter : String
    , options : List String
    }


type alias CheckboxColumnProps =
    { get : RowData -> Bool
    , set : RowData -> Bool -> RowData
    , filter : Maybe Bool
    }


type alias Row =
    { id : Int
    , data : RowData
    , checked : Bool
    }


type alias RowData =
    { selected : Bool
    , title : String
    , author : String
    , programCode : String
    , reviewCount : String
    , notes : String
    , category : String
    , decision : String
    }


type alias ContentCell =
    { id : Int
    , value : String
    }
