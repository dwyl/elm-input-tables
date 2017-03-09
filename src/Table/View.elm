module Table.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Keyed as Keyed
import Table.Messages exposing (..)
import Table.Model exposing (..)
import Table.RowFilter as RowFilter
import Table.ViewCell as ViewCell


-- add tests for filtering


view : TableState -> Html TableMsg
view model =
    let
        visibleColumns =
            List.filter .visible model.columns

        visibleRows =
            RowFilter.filter model.rows visibleColumns model.searchText model.externalFilter
    in
        div [ onClick TableClick ]
            [ div [ class "table__controls-wrapper" ]
                [ input
                    [ placeholder "Search"
                    , class "table__search"
                    , value model.searchText
                    , onInput UpdateSearchText
                    ]
                    []
                , button
                    [ class "table-bar__toggle-button button button--secondary", onClick ToggleChooseVisibleColumnsUi ]
                    [ text "Choose Visible Columns" ]
                , viewChooseVisibleColumnButtons model
                ]
            , table [ class "table" ]
                [ thead []
                    (viewHeaders model)
                , Keyed.node "tbody"
                    []
                    (List.map (viewTableRow model.columns) visibleRows)
                ]
            ]


viewChooseVisibleColumnButtons : TableState -> Html TableMsg
viewChooseVisibleColumnButtons model =
    div [ hidden (not model.showVisibleColumnsUi) ]
        (List.map
            (viewChooseVisibleColumnButton ToggleColumnVisibility)
            model.columns
        )


viewChooseVisibleColumnButton : (Int -> TableMsg) -> Column -> Html TableMsg
viewChooseVisibleColumnButton message column =
    button [ onClick (message column.id) ] [ text column.name ]


viewHeaders : TableState -> List (Html TableMsg)
viewHeaders model =
    [ tr [ class "table__header-row" ] ((checkboxHeader model) :: (viewOtherHeaders model)) ]


checkboxHeader : TableState -> Html TableMsg
checkboxHeader model =
    th [] [ checkbox ToggleAllRowsCheckboxes (List.all .checked model.rows) ]


checkbox : TableMsg -> Bool -> Html TableMsg
checkbox message checkedVal =
    input [ type_ "checkbox", checked checkedVal, onClick message ] []


viewOtherHeaders : TableState -> List (Html TableMsg)
viewOtherHeaders model =
    List.filterMap (viewHeader model.sorting) model.columns


viewHeader : Sorting -> Column -> Maybe (Html TableMsg)
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


viewTableRow : List Column -> Row -> ( String, Html TableMsg )
viewTableRow columns row =
    ( (toString row.id), tr [] ((checkboxCell row) :: (viewCells columns row)) )


checkboxCell row =
    td [ class "table-cell" ]
        [ checkbox (ToggleRowCheckbox row.id) row.checked
        , span [] [ text (toString row.id) ]
        ]


viewCells columns row =
    List.filterMap (ViewCell.view row) columns
