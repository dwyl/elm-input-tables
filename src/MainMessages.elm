module MainMessages exposing (..)

import InputTable.Messages exposing (..)
import MainModel exposing (..)


type Msg
    = Table (TableMsg RowData)
    | SetDecisionFilter DecisionFilter
    | SetStage Int
