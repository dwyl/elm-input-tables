module MainMessages exposing (..)

import MainModel exposing (..)


type Msg
    = UpdateCellValue (RowData -> String -> RowData) Int String
    | UpdateBoolCellValue (RowData -> Bool -> RowData) Int
    | UpdateSearchText String
    | UpdateColumnFilterText Int String
    | SwitchColumnCheckboxFilter Int (Maybe Bool)
    | ToggleRowCheckbox Int
    | ToggleAllRowsCheckboxes
    | ToggleChooseVisibleColumnsUi
    | ToggleColumnVisibility Int
    | SortRows Column
