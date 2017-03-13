module MainModel exposing (..)

import InputTable.Model


type alias Model =
    { tableState : InputTable.Model.TableState RowData
    , decisionFilter : DecisionFilter
    , stageId : Maybe Int
    , stages : List Stage
    }


type DecisionFilter
    = DecidedFilter
    | UndecidedFilter
    | NoFilter


type alias Stage =
    { id : Int
    , name : String
    }


type alias RowData =
    { conflictOfInterest : Bool
    , title : String
    , author : String
    , programCode : String
    , reviewCount : String
    , notes : String
    , category : String
    , decision : ( String, Maybe String )
    , stageId : Int
    }
