module MainUpdate exposing (update)

import MainMessages exposing (..)
import MainModel exposing (..)
import List.Extra exposing (updateIf)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateCellValue setter rowId value ->
            ( { model | rows = setCellData model.rows setter rowId value }, Cmd.none )

        UpdateSearchText value ->
            ( { model | searchText = value }, Cmd.none )

        UpdateColumnFilterText columnId value ->
            ( { model
                | columns =
                    updateFilterText columnId value model.columns
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
                    updateIfHasId columndId (\r -> { r | visible = not r.visible }) model.columns
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


updateFilterText columnId value columns =
    updateIfHasId columnId (\c -> { c | filterText = value }) columns


updateIfHasId id list =
    updateIf (\a -> a.id == id) list
