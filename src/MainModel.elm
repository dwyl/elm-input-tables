module MainModel exposing (..)


type alias Model =
    { contentColumns : List ContentColumn
    , inputColumns : List InputColumn
    , rows : List Row
    }


type alias ContentColumn =
    { id : Int
    , name : String
    }


type alias InputColumn =
    { id : Int
    , name : String
    , options : ColumnsOptions
    }


type ColumnsOptions
    = NoOptions
    | OptionsList (List String)


type alias Row =
    { id : Int
    , contentCells : List ContentCell
    , inputCells : List ContentCell
    }


type alias ContentCell =
    { id : Int
    , value : String
    }
