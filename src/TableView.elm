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
                |> List.filter containsSearchText

        visibleColumns =
            List.filter .visible (model.contentColumns ++ model.inputColumns)

        allColumnsPassFilter row =
            row.contentCells
                ++ row.inputCells
                |> List.map2 (,) visibleColumns
                |> List.all columnPassesFilter

        columnPassesFilter ( column, cell ) =
            contains column.filterText cell.value

        containsSearchText row =
            let
                cells =
                    row.contentCells ++ row.inputCells
            in
                contains model.searchText (toString row.id)
                    || (cells
                            |> List.map .value
                            |> List.any (contains model.searchText)
                       )
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
                    (List.map (viewTableRow model.contentColumns model.inputColumns) visibleRows)
                ]
            ]


viewChooseVisibleColumnButtons model =
    div [ hidden (not model.showVisibleColumnsUi) ]
        ((List.map
            (viewChooseVisibleColumnButton ToggleContentColumnVisibility)
            model.contentColumns
         )
            ++ (List.map
                    (viewChooseVisibleColumnButton ToggleInputColumnVisibility)
                    model.inputColumns
               )
        )


viewChooseVisibleColumnButton message column =
    button [ onClick (message column.id) ] [ text column.name ]


viewHeaders model =
    [ tr [] ((checkboxHeader model) :: (viewContentHeaders model) ++ (viewInputHeaders model)) ]


checkboxHeader model =
    th [] [ checkbox ToggleAllRowsCheckboxes (List.all .checked model.rows) ]


checkbox : Msg -> Bool -> Html Msg
checkbox message checkedVal =
    input [ type_ "checkbox", checked checkedVal, onClick message ] []


viewContentHeaders model =
    List.filterMap viewContentHeader model.contentColumns


viewContentHeader : Column -> Maybe (Html Msg)
viewContentHeader column =
    if column.visible then
        Just
            (th []
                [ div [] [ text column.name ]
                , input
                    [ placeholder "Filter"
                    , value column.filterText
                    , onInput (UpdateContentColumnFilterText column.id)
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
                    , onInput (UpdateInputColumnFilterText column.id)
                    ]
                    []
                ]
            )
    else
        Nothing


viewTableRow : List Column -> List Column -> Row -> Html Msg
viewTableRow contentColumns inputColumns row =
    tr [] ((checkboxCell row) :: (viewContentCells contentColumns row) ++ (viewInputCells inputColumns row))


checkboxCell row =
    td []
        [ checkbox (ToggleRowCheckbox row.id) row.checked
        , span [] [ text (toString row.id) ]
        ]


viewContentCells contentColumns row =
    List.map2 viewContentCell contentColumns row.contentCells


viewContentCell : Column -> ContentCell -> Html msg
viewContentCell contentColumn cell =
    if contentColumn.visible then
        td [] [ text cell.value ]
    else
        text ""


viewInputCells inputColumns row =
    List.map2 (viewInputCell row.id) inputColumns row.inputCells


viewInputCell rowId inputColumn cell =
    if inputColumn.visible then
        let
            viewOption val =
                option [ selected (val == cell.value) ] [ text val ]
        in
            case inputColumn.options of
                NoOptions ->
                    td []
                        [ input
                            [ onInput (UpdateInputCellValue rowId cell.id)
                            , value cell.value
                            ]
                            []
                        ]

                OptionsList options ->
                    td []
                        [ select [ onInput (UpdateInputCellValue rowId cell.id) ]
                            (List.map viewOption options)
                        ]
    else
        text ""
