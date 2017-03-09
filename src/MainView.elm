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

        newTableState rowData =
            { tableState | externalFilter = tableFilter }

        pendingFilterClass =
            if model.decisionFilter == UndecidedFilter then
                "table__tab table__tab--active"
            else
                "table__tab"

        decidedFilterClass =
            if model.decisionFilter == DecidedFilter then
                "table__tab table__tab--active"
            else
                "table__tab"

        allFilterClass =
            if model.decisionFilter == NoFilter then
                "table__tab table__tab--active"
            else
                "table__tab"
    in
        div []
            [ span []
                (viewStageButtons model.stages)
            , div
                [ class "table__wrapper" ]
                [ div [ class "table__tabs-wrapper" ]
                    [ span [ class pendingFilterClass, onClick (SetDecisionFilter UndecidedFilter) ] [ text "Pending" ]
                    , span [ class decidedFilterClass, onClick (SetDecisionFilter DecidedFilter) ] [ text "Decided" ]
                    , span [ class allFilterClass, onClick (SetDecisionFilter NoFilter) ] [ text "All" ]
                    ]
                , (Html.map (MainMessages.Table) (Table.View.view (newTableState RowData)))
                ]
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
