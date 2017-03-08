module MainUpdate exposing (update)

import List.Extra exposing (updateIf)
import Tuple exposing (first, second)
import MainMessages exposing (..)
import MainModel exposing (..)
import Table.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        tableState =
            model.tableState

        newTableState =
            Table.Update.update msg tableState
    in
        ( { model | tableState = newTableState }, Cmd.none )


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
