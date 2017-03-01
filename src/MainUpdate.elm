module MainUpdate exposing (update)

import MainMessages exposing (..)
import MainModel exposing (..)
import List.Extra exposing (updateIf)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateCellValue rowId cellId value ->
            ( model, Cmd.none )

        -- ( (updateInputCellValue model rowId cellId value), Cmd.none )
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



-- updateInputCellValue : Model -> Int -> Int -> String -> Model
-- updateInputCellValue model rowId cellId value =
--     let
--         updatedRows =
--             (updateIfHasId rowId) updateRow model.rows
--
--         updateRow row =
--             { row
--                 | rowData =
--                     (updateIfHasId cellId) (\c -> { c | value = value }) row.rowData
--             }
--     in
--         { model | rows = updatedRows }


updateFilterText columnId value columns =
    updateIfHasId columnId (\c -> { c | filterText = value }) columns


updateIfHasId id list =
    updateIf (\a -> a.id == id) list
