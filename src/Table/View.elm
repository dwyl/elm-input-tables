module Table.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Keyed as Keyed
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
                , Keyed.node "tbody"
                    []
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
            stringFilter config =
                input
                    [ placeholder "Filter"
                    , value config.filter
                    , onInput (UpdateColumnFilterText column.id)
                    ]
                    []

            boolFilter config =
                let
                    ( nextFilter, filterText ) =
                        case config.filter of
                            Nothing ->
                                ( Just True, "No Filter" )

                            Just True ->
                                ( Just False, "Checked" )

                            Just False ->
                                ( Nothing, "Unchecked" )
                in
                    a
                        [ onClick (SwitchColumnCheckboxFilter column.id nextFilter)
                        , style [ ( "cursor", "pointer" ) ]
                        ]
                        [ text filterText ]

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
                    , (case column.subType of
                        DisplayColumn props ->
                            stringFilter props

                        TextColumn props ->
                            stringFilter props

                        DropdownColumn props ->
                            stringFilter props

                        CheckboxColumn props ->
                            boolFilter props
                      )
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


viewTableRow : List Column -> Row -> ( String, Html Msg )
viewTableRow columns row =
    ( (toString row.id), tr [] ((checkboxCell row) :: (viewCells columns row)) )


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
            (td []
                (case column.subType of
                    DisplayColumn props ->
                        [ text (props.get row.data) ]

                    TextColumn props ->
                        [ (if props.isTextArea then
                            textarea
                           else
                            input
                          )
                            [ onInput (UpdateCellValue props.set row.id)
                            , value (props.get row.data)
                            ]
                            []
                        ]

                    DropdownColumn props ->
                        let
                            viewOption optionsValue =
                                option [ selected (optionsValue == (props.get row.data)) ] [ text optionsValue ]
                        in
                            [ select [ onInput (UpdateCellValue props.set row.id) ]
                                (List.map viewOption props.options)
                            ]

                    CheckboxColumn props ->
                        [ input
                            [ type_ "checkbox"
                            , checked (props.get row.data)
                            , onClick (UpdateBoolCellValue props.set row.id)
                            ]
                            []
                        ]
                )
            )
    else
        Nothing
