module MainView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import MainMessages exposing (..)
import MainModel exposing (..)
import Table.View
import Tuple exposing (first)


view model =
    let
        decisionFilter =
            getDecisionFilterFunction model

        stageFilter =
            case model.stageId of
                Nothing ->
                    (\row -> True)

                Just stageId ->
                    (\row -> row.data.stageId == stageId)

        tableFilter row =
            (decisionFilter row) && (stageFilter row)

        tableState =
            model.tableState

        newTableState =
            { tableState | externalFilter = tableFilter }
    in
        div []
            [ div [] (viewStageButtons model.stages)
            , div []
                [ button [ onClick (SetDecisionFilter UndecidedFilter) ] [ text "Pending" ]
                , button [ onClick (SetDecisionFilter DecidedFilter) ] [ text "Decided" ]
                , button [ onClick (SetDecisionFilter NoFilter) ] [ text "All" ]
                ]
            , (Html.map MainMessages.Table (Table.View.view newTableState))
            ]


viewStageButtons stages =
    if List.length stages < 2 then
        []
    else
        List.map viewStageButton stages


viewStageButton stage =
    button [ onClick (SetStage stage.id) ] [ text stage.name ]


getDecisionFilterFunction model =
    case model.decisionFilter of
        DecidedFilter ->
            (\row -> (first row.data.decision) /= "Pending")

        UndecidedFilter ->
            (\row -> (first row.data.decision) == "Pending")

        NoFilter ->
            (\row -> True)
