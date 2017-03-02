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
    , config : ColumnConfig
    }


type ColumnConfig
    = DisplayColumn DisplayColumnConfig
    | TextColumn TextColumnConfig
    | DropdownColumn DropdownColumnConfig
    | CheckboxColumn CheckboxColumnConfig


type alias DisplayColumnConfig =
    { get : RowData -> String
    , filter : String
    }


type alias TextColumnConfig =
    { get : RowData -> String
    , set : RowData -> String -> RowData
    , filter : String
    }


type alias DropdownColumnConfig =
    { get : RowData -> String
    , set : RowData -> String -> RowData
    , filter : String
    , options : List String
    }


type alias CheckboxColumnConfig =
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
    , reviewCount : String
    , notes : String
    , category : String
    , decision : String
    }


type alias ContentCell =
    { id : Int
    , value : String
    }
