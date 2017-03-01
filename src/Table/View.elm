module Table.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (checked, class, hidden, placeholder, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import MainMessages exposing (..)
import MainModel exposing (..)
import Table.RowFilter as RowFilter


-- add tests for filtering


view : Model -> Html Msg
view model =
    let
        visibleColumns =
            List.filter .visible model.columns

        visibleRows =
            RowFilter.filter model.rows visibleColumns model.searchText
    in
        div [ class "container" ]
            [ input
                [ placeholder "Search"
                , value model.searchText
                , onInput UpdateSearchText
                ]
                []
            , button
                [ class "button primary", onClick ToggleChooseVisibleColumnsUi ]
                [ text "Choose Visible Columns" ]
            , viewChooseVisibleColumnButtons model
            , table [ class "table table-condensed table-bordered" ]
                [ thead []
                    (viewHeaders model)
                , tbody []
                    (List.map (viewTableRow model.columns) visibleRows)
                ]
            ]


viewChooseVisibleColumnButtons model =
    div [ hidden (not model.showVisibleColumnsUi) ]
        (List.map
            (viewChooseVisibleColumnButton ToggleColumnVisibility)
            model.columns
        )


viewChooseVisibleColumnButton message column =
    button [ onClick (message column.id) ] [ text column.name ]


viewHeaders model =
    [ tr [] ((checkboxHeader model) :: (viewOtherHeaders model)) ]


checkboxHeader model =
    th [] [ checkbox ToggleAllRowsCheckboxes (List.all .checked model.rows) ]


checkbox : Msg -> Bool -> Html Msg
checkbox message checkedVal =
    input [ type_ "checkbox", checked checkedVal, onClick message ] []


viewOtherHeaders model =
    List.filterMap (viewHeader model.sorting) model.columns


viewHeader : Sorting -> Column -> Maybe (Html Msg)
viewHeader sorting column =
    if column.visible then
        let
            sortingText =
                case sorting of
                    NoSorting ->
                        "-"

                    Asc id ->
                        if id == column.id then
                            "Asc"
                        else
                            "-"

                    Desc id ->
                        if id == column.id then
                            "Desc"
                        else
                            "-"
        in
            Just
                (th []
                    [ div []
                        [ span [] [ text column.name ]
                        , button [ onClick (SortRows column) ] [ text sortingText ]
                        ]
                    , input
                        [ placeholder "Filter"
                        , value column.filterText
                        , onInput (UpdateColumnFilterText column.id)
                        ]
                        []
                    ]
                )
    else
        Nothing


viewInputHeaders model =
    List.filterMap viewInputHeader model.inputColumns


viewInputHeader column =
    if column.visible then
        Just
            (th
                []
                [ div [] [ text column.name ]
                , input
                    [ placeholder "Filter"
                    , value column.filterText
                    , onInput (UpdateColumnFilterText column.id)
                    ]
                    []
                ]
            )
    else
        Nothing


viewTableRow : List Column -> Row -> Html Msg
viewTableRow columns row =
    tr [] ((checkboxCell row) :: (viewCells columns row))


checkboxCell row =
    td []
        [ checkbox (ToggleRowCheckbox row.id) row.checked
        , span [] [ text (toString row.id) ]
        ]


viewCells columns row =
    List.filterMap (viewCell row) columns


viewCell : Row -> Column -> Maybe (Html Msg)
viewCell row column =
    if column.visible then
        let
            val =
                column.getVal row.data
        in
            Just
                (case column.input of
                    NoColumnInput ->
                        td [] [ text (column.getVal row.data) ]

                    TextColumnInput setter ->
                        td []
                            [ input
                                [ onInput (UpdateCellValue setter row.id)
                                , value val
                                ]
                                []
                            ]

                    DropdownColumnInput setter options ->
                        let
                            viewOption optionsValue =
                                option [ selected (optionsValue == val) ] [ text optionsValue ]
                        in
                            td []
                                [ select [ onInput (UpdateCellValue setter row.id) ]
                                    (List.map viewOption options)
                                ]
                )
    else
        Nothing
