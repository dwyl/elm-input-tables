module MainUpdate exposing (update)

import MainMessages exposing (..)
import MainModel exposing (..)
import List.Extra exposing (updateIf)
import Tuple exposing (first, second)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateCellValue setter rowId value ->
            ( { model | rows = setCellData model.rows setter rowId value }, Cmd.none )

        UpdateBoolCellValue setter rowId ->
            ( { model | rows = setCellData model.rows setter rowId True }, Cmd.none )

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
                ( { model
                    | columns =
                        updateIfHasId columnId update model.columns
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
                ( { model
                    | columns = updateIfHasId columnId updateColumn model.columns
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
                ( { model
                    | columns = updateIfHasId columnId updateColumn model.columns
                    , rows = updateIfHasId rowId updateRow model.rows
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
                ( { model
                    | columns = updateIfHasId columnId updateColumn model.columns
                    , rows = updateIfHasId rowId updateRow model.rows
                  }
                , Cmd.none
                )

        UpdateSearchText value ->
            ( { model | searchText = value }, Cmd.none )

        UpdateColumnFilterText columnId value ->
            ( { model
                | columns =
                    updateFilterText columnId value model.columns
              }
            , Cmd.none
            )

        SwitchColumnCheckboxFilter columnId newFilterState ->
            ( { model
                | columns =
                    switchCheckboxFilter columnId newFilterState model.columns
              }
            , Cmd.none
            )

        ToggleRowCheckbox rowId ->
            ( { model
                | rows =
                    updateIfHasId rowId (\r -> { r | checked = not r.checked }) model.rows
              }
            , Cmd.none
            )

        ToggleAllRowsCheckboxes ->
            let
                allChecked =
                    List.all .checked model.rows

                newRows =
                    List.map (\r -> { r | checked = not allChecked }) model.rows
            in
                ( { model | rows = newRows }, Cmd.none )

        ToggleChooseVisibleColumnsUi ->
            ( { model | showVisibleColumnsUi = not model.showVisibleColumnsUi }, Cmd.none )

        ToggleColumnVisibility columndId ->
            ( { model
                | columns =
                    updateIfHasId columndId (\c -> { c | visible = not c.visible }) model.columns
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
                    case model.sorting of
                        Asc currentSortId ->
                            if currentSortId == id then
                                ( sortByVal model.rows get False, Desc id )
                            else
                                ( sortByVal model.rows get True, Asc id )

                        _ ->
                            ( sortByVal model.rows get True, Asc id )
            in
                ( { model
                    | rows = first sortedByVals
                    , sorting = second sortedByVals
                  }
                , Cmd.none
                )


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
