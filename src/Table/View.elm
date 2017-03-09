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


view : TableState rowData -> Html (TableMsg rowData)
view tableState =
    let
        visibleColumns =
            List.filter .visible tableState.columns

        visibleRows =
            RowFilter.filter tableState.rows visibleColumns tableState.searchText tableState.externalFilter
    in
        div [ onClick TableClick ]
            [ div [ class "table__controls-wrapper" ]
                [ input
                    [ placeholder "Search"
                    , class "table__search"
                    , value tableState.searchText
                    , onInput UpdateSearchText
                    ]
                    []
                , button
                    [ class "table-bar__toggle-button button button--secondary", onClick ToggleChooseVisibleColumnsUi ]
                    [ text "Choose Visible (Column rowData)s" ]
                , viewChooseVisibleColumnButtons tableState
                ]
            , table [ class "table" ]
                [ thead []
                    (viewHeaders tableState)
                , Keyed.node "tbody"
                    []
                    (List.map (viewTableRow tableState.columns) visibleRows)
                ]
            ]


viewChooseVisibleColumnButtons : TableState rowData -> Html (TableMsg rowData)
viewChooseVisibleColumnButtons tableState =
    div [ hidden (not tableState.showVisibleColumnsUi) ]
        (List.map
            (viewChooseVisibleColumnButton ToggleColumnVisibility)
            tableState.columns
        )


viewChooseVisibleColumnButton : (Int -> TableMsg rowData) -> Column rowData -> Html (TableMsg rowData)
viewChooseVisibleColumnButton message column =
    button [ onClick (message column.id) ] [ text column.name ]


viewHeaders : TableState rowData -> List (Html (TableMsg rowData))
viewHeaders model =
    [ tr [ class "table__header-row" ] ((checkboxHeader model) :: (viewOtherHeaders model)) ]


checkboxHeader : TableState rowData -> Html (TableMsg rowData)
checkboxHeader model =
    th [] [ checkbox ToggleAllRowsCheckboxes (List.all .checked model.rows) ]


checkbox : TableMsg rowData -> Bool -> Html (TableMsg rowData)
checkbox message checkedVal =
    input [ type_ "checkbox", checked checkedVal, onClick message ] []


viewOtherHeaders : TableState rowData -> List (Html (TableMsg rowData))
viewOtherHeaders model =
    List.filterMap (viewHeader model.sorting) model.columns


viewHeader : Sorting -> Column rowData -> Maybe (Html (TableMsg rowData))
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


viewTableRow : List (Column rowData) -> Row rowData -> ( String, Html (TableMsg rowData) )
viewTableRow columns row =
    ( (toString row.id), tr [] ((checkboxCell row) :: (viewCells columns row)) )


checkboxCell : Row rowData -> Html (TableMsg rowData)
checkboxCell row =
    td [ class "table-cell" ]
        [ checkbox (ToggleRowCheckbox row.id) row.checked
        , span [] [ text (toString row.id) ]
        ]


viewCells : List (Column rowData) -> Row rowData -> List (Html (TableMsg rowData))
viewCells columns row =
    List.filterMap (ViewCell.view row) columns
