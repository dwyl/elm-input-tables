module Table.Update exposing (update)

import Table.Messages exposing (..)
import Table.Model exposing (..)
import List.Extra exposing (updateIf)
import Tuple exposing (first, second)


update : TableMsg rowData -> State rowData -> ( State rowData, Cmd TableMsg )
update msg state =
    case msg of
        UpdateCellValue setter rowId value ->
            ( { state | rows = setCellData state.rows setter rowId value }, Cmd.none )

        UpdateBoolCellValue setter rowId ->
            ( { state | rows = setCellData state.rows setter rowId True }, Cmd.none )

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
                ( { state
                    | columns =
                        updateIfHasId columnId update state.columns
                  }
                , Cmd.none
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
                ( { state
                    | columns = updateIfHasId columnId updateColumn state.columns
                  }
                , Cmd.none
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
                ( { state
                    | columns = updateIfHasId columnId updateColumn state.columns
                    , rows = updateIfHasId rowId updateRow state.rows
                  }
                , Cmd.none
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
                ( { state
                    | columns = updateIfHasId columnId updateColumn state.columns
                    , rows = updateIfHasId rowId updateRow state.rows
                  }
                , Cmd.none
                )

        UpdateSearchText value ->
            ( { state | searchText = value }, Cmd.none )

        UpdateColumnFilterText columnId value ->
            ( { state
                | columns =
                    updateFilterText columnId value state.columns
              }
            , Cmd.none
            )

        SwitchColumnCheckboxFilter columnId newFilterState ->
            ( { state
                | columns =
                    switchCheckboxFilter columnId newFilterState state.columns
              }
            , Cmd.none
            )

        ToggleRowCheckbox rowId ->
            ( { state
                | rows =
                    updateIfHasId rowId (\r -> { r | checked = not r.checked }) state.rows
              }
            , Cmd.none
            )

        ToggleAllRowsCheckboxes ->
            let
                allChecked =
                    List.all .checked state.rows

                newRows =
                    List.map (\r -> { r | checked = not allChecked }) state.rows
            in
                ( { state | rows = newRows }, Cmd.none )

        ToggleChooseVisibleColumnsUi ->
            ( { state | showVisibleColumnsUi = not state.showVisibleColumnsUi }, Cmd.none )

        ToggleColumnVisibility columndId ->
            ( { state
                | columns =
                    updateIfHasId columndId (\c -> { c | visible = not c.visible }) state.columns
              }
            , Cmd.none
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
                    case state.sorting of
                        Asc currentSortId ->
                            if currentSortId == id then
                                ( sortByVal state.rows get False, Desc id )
                            else
                                ( sortByVal state.rows get True, Asc id )

                        _ ->
                            ( sortByVal state.rows get True, Asc id )
            in
                ( { state
                    | rows = first sortedByVals
                    , sorting = second sortedByVals
                  }
                , Cmd.none
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
                ( { state | columns = List.map removeFocus state.columns }, Cmd.none )


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


updateIfHasId id list =
    updateIf (\a -> a.id == id) list
