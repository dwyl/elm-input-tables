module MainModel exposing (..)

import Table.Model


type alias Model =
    { tableState : Table.Model.TableState
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
