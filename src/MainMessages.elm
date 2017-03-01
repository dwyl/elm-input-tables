module MainMessages exposing (..)

import MainModel exposing (..)


type Msg
    = UpdateCellValue (RowData -> String -> RowData) Int String
    | UpdateSearchText String
    | UpdateColumnFilterText Int String
    | ToggleRowCheckbox Int
    | ToggleAllRowsCheckboxes
    | ToggleChooseVisibleColumnsUi
    | ToggleColumnVisibility Int
