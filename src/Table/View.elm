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

        unfilteredRows =
            RowFilter.run
                tableState.rows
                visibleColumns
                tableState.searchText
                tableState.externalFilter

        visibleRows =
            getPageRows tableState unfilteredRows

        tableButtonDropdownClass =
            if tableState.showVisibleColumnsUi then
                "table__button-dropdown table__button-dropdown--active"
            else
                "table__button-dropdown"
    in
        div [ onClick TableClick ]
            [ div [ class "table__controls-wrapper" ]
                [ input
                    [ placeholder "Search"
                    , class "table__search"
                    , value tableState.searchText
                    , onInput SetSearchText
                    ]
                    []
                , viewPageControls tableState unfilteredRows
                , button
                    [ class tableButtonDropdownClass, onClick ToggleChooseVisibleColumnsUi ]
                    [ text "Choose Visible Columns" ]
                , viewChooseVisibleColumnButtons tableState
                ]
            , table [ class "table" ]
                [ thead []
                    (viewHeaders tableState visibleRows)
                , Keyed.node "tbody"
                    []
                    (List.map (viewTableRow tableState.columns) visibleRows)
                ]
            ]


getPageRows : TableState rowData -> List (Row rowData) -> List (Row rowData)
getPageRows { pageSize, currentPage } visibleRows =
    case pageSize of
        Nothing ->
            visibleRows

        Just pageSize ->
            let
                start =
                    pageSize * (currentPage - 1)
            in
                visibleRows
                    |> List.drop start
                    |> List.take pageSize


viewPageControls : TableState rowData -> List (Row rowData) -> Html (TableMsg rowData)
viewPageControls { pageSize, currentPage } visibleRows =
    case pageSize of
        Nothing ->
            text ""

        Just pageSize ->
            let
                start =
                    toString (pageSize * (currentPage - 1))

                end =
                    toString (Basics.min (pageSize * currentPage) (List.length visibleRows))

                total =
                    toString (List.length visibleRows)
            in
                span []
                    [ span [] [ text (start ++ " - " ++ end ++ " of " ++ total) ]
                    , span
                        [ style [ ( "cursor", "pointer" ) ]
                        , onClick PreviousPage
                        ]
                        [ text " Previous " ]
                    , span
                        [ style [ ( "cursor", "pointer" ) ]
                        , onClick (NextPage (List.length visibleRows))
                        ]
                        [ text " Next " ]
                    ]


viewChooseVisibleColumnButtons : TableState rowData -> Html (TableMsg rowData)
viewChooseVisibleColumnButtons tableState =
    if tableState.showVisibleColumnsUi then
        div [ class "bar bar--table" ]
            (List.map
                (viewChooseVisibleColumnButton ToggleColumnVisibility)
                tableState.columns
            )
    else
        text ""


viewChooseVisibleColumnButton : (Int -> TableMsg rowData) -> Column rowData -> Html (TableMsg rowData)
viewChooseVisibleColumnButton message column =
    let
        extraClass =
            if column.visible then
                " bar__toggle--active"
            else
                ""
    in
        a [ class ("bar__toggle" ++ extraClass), onClick (message column.id) ] [ text column.name ]


viewHeaders : TableState rowData -> List (Row rowData) -> List (Html (TableMsg rowData))
viewHeaders model visibleRows =
    [ tr [ class "table__header-row" ] ((checkboxHeader model visibleRows) :: (viewOtherHeaders model)) ]


checkboxHeader : TableState rowData -> List (Row rowData) -> Html (TableMsg rowData)
checkboxHeader model visibleRows =
    th []
        [ label
            [ class "table-cell--select-checkbox__label" ]
            [ checkbox
                (ToggleVisibleRowsCheckboxes visibleRows)
                (List.all .checked visibleRows)
            ]
        ]


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
                    , onInput (SetColumnFilterText column.id)
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
                        , class "table-header__bool-filter"
                        ]
                        [ text filterText ]

            sortingClass =
                case sorting of
                    NoSorting ->
                        "table-header__icon"

                    Asc id ->
                        if id == column.id then
                            "table-header__icon--asc"
                        else
                            "table-header__icon"

                    Desc id ->
                        if id == column.id then
                            "table-header__icon--desc"
                        else
                            "table-header__icon"

            ( filterElement, headerClass ) =
                (case column.subType of
                    DisplayColumn props ->
                        ( stringFilter props, "" )

                    TextColumn props ->
                        ( stringFilter props, " table-header--control" )

                    DropdownColumn props ->
                        ( stringFilter props, " table-header--control" )

                    SubDropdownColumn props ->
                        ( stringFilter props, " table-header--control" )

                    CheckboxColumn props ->
                        ( boolFilter props, " table-header--control" )
                )
        in
            Just
                (th [ class ("table-header" ++ headerClass) ]
                    [ div [ class "table-header__sort-wrapper", onClick (SortRows column) ]
                        [ span [ class "table-header__name" ] [ text column.name ]
                        , i [ class ("table-header__icon " ++ sortingClass) ] []
                        ]
                    , filterElement
                    ]
                )
    else
        Nothing


viewTableRow : List (Column rowData) -> Row rowData -> ( String, Html (TableMsg rowData) )
viewTableRow columns row =
    ( (toString row.id), tr [] ((checkboxCell row) :: (viewCells columns row)) )


checkboxCell : Row rowData -> Html (TableMsg rowData)
checkboxCell row =
    td [ class "table-cell table-cell--select-checkbox" ]
        [ label [ class "table-cell--select-checkbox__label" ]
            [ checkbox (ToggleRowCheckbox row.id) row.checked
            ]
        ]


viewCells : List (Column rowData) -> Row rowData -> List (Html (TableMsg rowData))
viewCells columns row =
    List.filterMap (ViewCell.view row) columns
