module MainModel exposing (..)


type alias Model =
    { contentColumns : List Column
    , inputColumns : List Column
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
    }


type ColumnsOptions
    = NoOptions
    | OptionsList (List String)


type alias Row =
    { id : Int
    , contentCells : List ContentCell
    , inputCells : List ContentCell
    , checked : Bool
    }


type alias ContentCell =
    { id : Int
    , value : String
    }
