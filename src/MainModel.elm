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
    , filterText : String
    , options : ColumnsOptions
    , visible : Bool
    , inputType : ColumnInput
    }


type ColumnInput
    = NoColumnInput
    | TextColumnInput
    | DropdownColumnInput


type ColumnsOptions
    = NoOptions
    | OptionsList (List String)


type alias Row =
    { id : Int
    , cells : List ContentCell
    , checked : Bool
    }


type alias ContentCell =
    { id : Int
    , value : String
    }
