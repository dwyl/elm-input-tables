module Table.Update exposing (update)

import Table.Messages exposing (..)
import Table.Model exposing (..)
import List.Extra exposing (updateIf)
import Set


update : TableMsg rowData -> TableState rowData -> TableState rowData
update msg tableState =
    case msg of
        SetCellValue setter rowId value ->
            ({ tableState | rows = setCellData tableState.rows setter rowId value })

        SetBoolCellValue setter rowId ->
            ({ tableState | rows = setCellData tableState.rows setter rowId True })

        ToggleCellDropdown rowId columnId ->
            let
                update column =
                    case column.subType of
                        SubDropdownColumn props ->
                            let
                                newProps =
                                    (case props.focussedRowId of
                                        Just currentFocussedRowId ->
                                            if currentFocussedRowId == rowId then
                                                { props
                                                    | focussedRowId = Nothing
                                                    , focussedOption = Nothing
                                                }
                                            else
                                                { props
                                                    | focussedRowId = Just rowId
                                                    , focussedOption = Nothing
                                                }

                                        Nothing ->
                                            { props
                                                | focussedRowId = Just rowId
                                                , focussedOption = Nothing
                                            }
                                    )
                            in
                                { column | subType = SubDropdownColumn newProps }

                        _ ->
                            column
            in
                ({ tableState
                    | columns =
                        updateIfHasId columnId update tableState.columns
                 }
                )

        ViewDropdownChildren rowId columnId choice set ->
            let
                updateColumn column =
                    case column.subType of
                        SubDropdownColumn props ->
                            let
                                newProps =
                                    { props
                                        | focussedRowId = Just rowId
                                        , focussedOption = Just choice
                                    }
                            in
                                { column | subType = SubDropdownColumn newProps }

                        _ ->
                            column
            in
                ({ tableState
                    | columns = updateIfHasId columnId updateColumn tableState.columns
                 }
                )

        SelectDropdownParent rowId columnId choice set ->
            let
                updateColumn column =
                    case column.subType of
                        SubDropdownColumn props ->
                            let
                                newProps =
                                    { props
                                        | focussedRowId = Nothing
                                        , focussedOption = Nothing
                                    }
                            in
                                { column | subType = SubDropdownColumn newProps }

                        _ ->
                            column

                updateRow row =
                    { row | data = set row.data ( choice, Nothing ) }
            in
                ({ tableState
                    | columns = updateIfHasId columnId updateColumn tableState.columns
                    , rows = updateIfHasId rowId updateRow tableState.rows
                 }
                )

        SelectDropdownChild rowId columnId choice subChoice set ->
            let
                updateColumn column =
                    case column.subType of
                        SubDropdownColumn props ->
                            let
                                newProps =
                                    { props
                                        | focussedRowId = Nothing
                                        , focussedOption = Nothing
                                    }
                            in
                                { column | subType = SubDropdownColumn newProps }

                        _ ->
                            column

                updateRow row =
                    { row | data = set row.data ( choice, Just subChoice ) }
            in
                ({ tableState
                    | columns = updateIfHasId columnId updateColumn tableState.columns
                    , rows = updateIfHasId rowId updateRow tableState.rows
                 }
                )

        SetSearchText value ->
            ({ tableState | searchText = value, currentPage = 1 })

        SetColumnFilterText columnId value ->
            ({ tableState
                | columns =
                    updateFilterText columnId value tableState.columns
                , currentPage = 1
             }
            )

        SwitchColumnCheckboxFilter columnId newFilterState ->
            ({ tableState
                | columns =
                    switchCheckboxFilter columnId newFilterState tableState.columns
             }
            )

        ToggleRowCheckbox rowId ->
            ({ tableState
                | rows =
                    updateIfHasId rowId (\r -> { r | checked = not r.checked }) tableState.rows
             }
            )

        ToggleVisibleRowsCheckboxes visibleRows ->
            let
                allChecked =
                    List.all .checked visibleRows

                visibleRowsIds =
                    visibleRows
                        |> List.map .id
                        |> Set.fromList

                newRows =
                    List.map setChecked tableState.rows

                setChecked row =
                    if Set.member row.id visibleRowsIds then
                        { row | checked = not allChecked }
                    else
                        row
            in
                ({ tableState | rows = newRows })

        ToggleChooseVisibleColumnsUi ->
            ({ tableState | showVisibleColumnsUi = not tableState.showVisibleColumnsUi })

        ToggleColumnVisibility columndId ->
            ({ tableState
                | columns =
                    updateIfHasId columndId (\c -> { c | visible = not c.visible }) tableState.columns
             }
            )

        SortRows { id, subType } ->
            let
                ( rows, sorting ) =
                    case subType of
                        DisplayColumn subType ->
                            sortComparable subType.get

                        TextColumn subType ->
                            sortComparable subType.get

                        DropdownColumn subType ->
                            sortComparable subType.get

                        SubDropdownColumn subType ->
                            sortComparable (subType.get >> convertSubDropdownToString)

                        CheckboxColumn subType ->
                            sortComparable (subType.get >> converBoolToString)

                convertSubDropdownToString ( choice, subChoice ) =
                    choice ++ (Maybe.withDefault "" subChoice)

                converBoolToString bool =
                    if bool then
                        "1"
                    else
                        "0"

                sortComparable get =
                    case tableState.sorting of
                        Asc currentSortId ->
                            if currentSortId == id then
                                ( sortByVal tableState.rows get False, Desc id )
                            else
                                ( sortByVal tableState.rows get True, Asc id )

                        _ ->
                            ( sortByVal tableState.rows get True, Asc id )
            in
                ({ tableState
                    | rows = rows
                    , sorting = sorting
                 }
                )

        TableClick ->
            let
                removeFocus column =
                    case column.subType of
                        SubDropdownColumn props ->
                            let
                                newProps =
                                    { props
                                        | focussedRowId = Nothing
                                        , focussedOption = Nothing
                                    }
                            in
                                { column | subType = SubDropdownColumn newProps }

                        _ ->
                            column
            in
                { tableState | columns = List.map removeFocus tableState.columns }

        PreviousPage ->
            { tableState | currentPage = max (tableState.currentPage - 1) 1 }

        NextPage rowCount ->
            let
                maxPage =
                    (rowCount // (Maybe.withDefault 1 tableState.pageSize)) + 1
            in
                { tableState | currentPage = min (tableState.currentPage + 1) maxPage }


setCellData : List (Row rowData) -> (rowData -> a -> rowData) -> Int -> a -> List (Row rowData)
setCellData rows setter rowId value =
    let
        update row =
            { row | data = setter row.data value }
    in
        updateIfHasId rowId update rows


updateFilterText : Int -> String -> List (Column rowData) -> List (Column rowData)
updateFilterText columnId value columns =
    let
        updateIfText column =
            case column.subType of
                DisplayColumn props ->
                    DisplayColumn (update props)

                TextColumn props ->
                    TextColumn (update props)

                DropdownColumn props ->
                    DropdownColumn (update props)

                SubDropdownColumn props ->
                    SubDropdownColumn (update props)

                CheckboxColumn props ->
                    CheckboxColumn props

        update props =
            { props | filter = value }
    in
        updateIfHasId columnId (\c -> { c | subType = updateIfText c }) columns


switchCheckboxFilter : Int -> Maybe Bool -> List (Column rowData) -> List (Column rowData)
switchCheckboxFilter columnId newFilterState columns =
    let
        updateIfText column =
            case column.subType of
                DisplayColumn props ->
                    DisplayColumn props

                TextColumn props ->
                    TextColumn props

                DropdownColumn props ->
                    DropdownColumn props

                SubDropdownColumn props ->
                    SubDropdownColumn props

                CheckboxColumn props ->
                    CheckboxColumn (update props)

        update props =
            { props | filter = newFilterState }
    in
        updateIfHasId columnId (\c -> { c | subType = updateIfText c }) columns


sortByVal : List (Row rowData) -> (rowData -> String) -> Bool -> List (Row rowData)
sortByVal rows getVal ascending =
    let
        comparator row1 row2 =
            case compare (getVal row1.data) (getVal row2.data) of
                LT ->
                    LT

                GT ->
                    GT

                EQ ->
                    (compare row1.id row2.id)
    in
        if ascending then
            List.sortWith comparator rows
        else
            rows
                |> List.sortWith comparator
                |> List.reverse


updateIfHasId : a -> ({ b | id : a } -> { b | id : a }) -> List { b | id : a } -> List { b | id : a }
updateIfHasId id list =
    updateIf (\a -> a.id == id) list
