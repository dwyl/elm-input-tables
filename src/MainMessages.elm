module MainMessages exposing (..)

import MainModel exposing (..)


type Msg
    = UpdateCellValue (RowData -> String -> RowData) Int String
    | UpdateBoolCellValue (RowData -> Bool -> RowData) Int
    | ToggleCellDropdown Int Int
    | SelectDropdownParent Int Int String (RowData -> ( String, Maybe String ) -> RowData)
    | ViewDropdownChildren Int Int String (RowData -> ( String, Maybe String ) -> RowData)
    | SelectDropdownChild Int Int String String (RowData -> ( String, Maybe String ) -> RowData)
    | UpdateSearchText String
    | UpdateColumnFilterText Int String
    | SwitchColumnCheckboxFilter Int (Maybe Bool)
    | ToggleRowCheckbox Int
    | ToggleAllRowsCheckboxes
    | ToggleChooseVisibleColumnsUi
    | ToggleColumnVisibility Int
    | SortRows Column
