module MainMessages exposing (..)


type Msg
    = UpdateCellValue Int Int String
    | UpdateSearchText String
    | UpdateColumnFilterText Int String
    | ToggleRowCheckbox Int
    | ToggleAllRowsCheckboxes
    | ToggleChooseVisibleColumnsUi
    | ToggleColumnVisibility Int
