module MainMessages exposing (..)

import Table.Messages exposing (..)
import MainModel exposing (..)


type Msg
    = Table TableMsg
    | SetDecisionFilter DecisionFilter
    | SetStage Int
