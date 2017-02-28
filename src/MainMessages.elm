module MainMessages exposing (..)


type Msg
    = UpdateContentCellValue Int String
    | UpdateInputCellValue Int Int String
    | UpdateSearchText String
    | UpdateInputColumnFilterText Int String
    | UpdateContentColumnFilterText Int String
    | ToggleRowCheckbox Int
    | ToggleAllRowsCheckboxes
    | ToggleChooseVisibleColumnsUi
    | ToggleContentColumnVisibility Int
    | ToggleInputColumnVisibility Int
