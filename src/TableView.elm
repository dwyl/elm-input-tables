module TableView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (checked, class, hidden, placeholder, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import String exposing (contains, toLower)
import MainMessages exposing (..)
import MainModel exposing (..)


-- add tests for filtering


view : Model -> Html Msg
view model =
    let
        visibleRows =
            model.rows
                |> List.filter allColumnsPassFilter

        -- |> List.filter containsSearchText
        visibleColumns =
            List.filter .visible model.columns

        allColumnsPassFilter row =
            List.all (columnPassesFilter row) visibleColumns

        columnPassesFilter row column =
            contains column.filterText (column.getVal row.data)
                && contains model.searchText (column.getVal row.data)
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
    List.filterMap viewHeader model.columns


viewHeader : Column -> Maybe (Html Msg)
viewHeader column =
    if column.visible then
        Just
            (th []
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
        Just
            (case column.inputType of
                NoColumnInput ->
                    td [] [ text (column.getVal row.data) ]

                TextColumnInput ->
                    td []
                        [ input
                            [ onInput (UpdateCellValue row.id row.id)
                            , value (column.getVal row.data)
                            ]
                            []
                        ]

                DropdownColumnInput options ->
                    let
                        viewOption val =
                            option [ selected (val == (column.getVal row.data)) ] [ text val ]
                    in
                        td []
                            [ select [ onInput (UpdateCellValue row.id row.id) ]
                                (List.map viewOption options)
                            ]
            )
    else
        Nothing
