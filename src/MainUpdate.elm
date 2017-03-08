module MainUpdate exposing (update)

import MainMessages exposing (..)
import MainModel exposing (..)
import Table.Update
import Tuple exposing (first)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Table tableMsg ->
            let
                newTableState =
                    Table.Update.update tableMsg model.tableState
            in
                ( { model | tableState = newTableState }, Cmd.none )

        SetDecisionFilter decisionFilter ->
            ( { model | decisionFilter = decisionFilter }, Cmd.none )

        SetStage stageId ->
            ( { model | stageId = Just stageId }, Cmd.none )
