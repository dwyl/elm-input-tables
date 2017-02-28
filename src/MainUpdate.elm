module MainUpdate exposing (update)

import MainMessages exposing (..)
import MainModel exposing (..)
import List.Extra exposing (updateIf)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateContentCellValue id value ->
            ( model, Cmd.none )

        UpdateInputCellValue rowId cellId value ->
            ( (updateInputCellValue model rowId cellId value), Cmd.none )

        UpdateSearchText value ->
            ( { model | searchText = value }, Cmd.none )

        UpdateInputColumnFilterText columnId value ->
            ( { model
                | inputColumns =
                    updateFilterText columnId value model.inputColumns
              }
            , Cmd.none
            )

        UpdateContentColumnFilterText columnId value ->
            ( { model
                | contentColumns =
                    updateFilterText columnId value model.contentColumns
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

        ToggleContentColumnVisibility columndId ->
            ( { model
                | contentColumns =
                    updateIfHasId columndId (\r -> { r | visible = not r.visible }) model.contentColumns
              }
            , Cmd.none
            )

        ToggleInputColumnVisibility columndId ->
            ( { model
                | inputColumns =
                    updateIfHasId columndId (\r -> { r | visible = not r.visible }) model.inputColumns
              }
            , Cmd.none
            )


updateInputCellValue : Model -> Int -> Int -> String -> Model
updateInputCellValue model rowId cellId value =
    let
        updatedRows =
            (updateIfHasId rowId) updateRow model.rows

        updateRow row =
            { row
                | inputCells =
                    (updateIfHasId cellId) (\c -> { c | value = value }) row.inputCells
            }
    in
        { model | rows = updatedRows }


updateFilterText columnId value columns =
    updateIfHasId columnId (\c -> { c | filterText = value }) columns


updateIfHasId id list =
    updateIf (\a -> a.id == id) list
