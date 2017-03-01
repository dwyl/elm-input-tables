module MainModel exposing (..)


type alias Model =
    { columns : List Column
    , rows : List Row
    , searchText : String
    , showVisibleColumnsUi : Bool
    }


type alias Column =
    { id : Int
    , name : String
    , getVal : RowData -> String
    , filterText : String
    , visible : Bool
    , inputType : ColumnInput
    }


type ColumnInput
    = NoColumnInput
    | TextColumnInput
    | DropdownColumnInput (List String)


type alias Row =
    { id : Int
    , data : RowData
    , checked : Bool
    }


type alias RowData =
    { title : String
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
