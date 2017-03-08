module Table.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Keyed as Keyed
import MainMessages exposing (..)
import MainModel exposing (..)
import Table.RowFilter as RowFilter
import Table.ViewCell as ViewCell


-- add tests for filtering


view : Model -> Html Msg
view model =
    let
        visibleColumns =
            List.filter .visible model.columns

        visibleRows =
            RowFilter.filter model.rows visibleColumns model.searchText
    in
        div [ class "container", onClick TableClick ]
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


viewChooseVisibleColumnButtons : Model -> Html Msg
viewChooseVisibleColumnButtons model =
    div [ hidden (not model.showVisibleColumnsUi) ]
        (List.map
            (viewChooseVisibleColumnButton ToggleColumnVisibility)
            model.columns
        )


viewChooseVisibleColumnButton : (Int -> Msg) -> Column -> Html Msg
viewChooseVisibleColumnButton message column =
    button [ onClick (message column.id) ] [ text column.name ]


viewHeaders : Model -> List (Html Msg)
viewHeaders model =
    [ tr [] ((checkboxHeader model) :: (viewOtherHeaders model)) ]


checkboxHeader : Model -> Html Msg
checkboxHeader model =
    th [] [ checkbox ToggleAllRowsCheckboxes (List.all .checked model.rows) ]


checkbox : Msg -> Bool -> Html Msg
checkbox message checkedVal =
    input [ type_ "checkbox", checked checkedVal, onClick message ] []


viewOtherHeaders : Model -> List (Html Msg)
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

                        SubDropdownColumn props ->
                            stringFilter props

                        CheckboxColumn props ->
                            boolFilter props
                      )
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
    List.filterMap (ViewCell.view row) columns
