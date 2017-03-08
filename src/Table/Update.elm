module Table.Update exposing (update)

import Table.Messages exposing (..)
import MainModel exposing (..)
import List.Extra exposing (updateIf)
import Tuple exposing (first, second)


update : Msg -> TableState -> TableState
update msg tableState =
    case msg of
        UpdateCellValue setter rowId value ->
            ({ tableState | rows = setCellData tableState.rows setter rowId value })

        UpdateBoolCellValue setter rowId ->
            ({ tableState | rows = setCellData tableState.rows setter rowId True })

        ToggleCellDropdown rowId columnId ->
            let
                update column =
                    case column.subType of
                        SubDropdownColumn props ->
                            let
                                newProps =
                                    { props
                                        | focussedRowId = Just rowId
                                        , focussedOption = Nothing
                                    }
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

        UpdateSearchText value ->
            ({ tableState | searchText = value })

        UpdateColumnFilterText columnId value ->
            ({ tableState
                | columns =
                    updateFilterText columnId value tableState.columns
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

        ToggleAllRowsCheckboxes ->
            let
                allChecked =
                    List.all .checked tableState.rows

                newRows =
                    List.map (\r -> { r | checked = not allChecked }) tableState.rows
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
                sortedByVals =
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
                    | rows = first sortedByVals
                    , sorting = second sortedByVals
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
                ({ tableState | columns = List.map removeFocus tableState.columns })


setCellData : List Row -> (RowData -> a -> RowData) -> Int -> a -> List Row
setCellData rows setter rowId value =
    let
        update row =
            { row | data = setter row.data value }
    in
        updateIfHasId rowId update rows


updateFilterText : Int -> String -> List Column -> List Column
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


sortByVal : List Row -> (RowData -> String) -> Bool -> List Row
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


updateIfHasId id list =
    updateIf (\a -> a.id == id) list
