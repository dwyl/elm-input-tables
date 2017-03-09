module Table.Messages exposing (..)

import Table.Model exposing (..)


type TableMsg rowData
    = UpdateCellValue (rowData -> String -> rowData) Int String
    | UpdateBoolCellValue (rowData -> Bool -> rowData) Int
    | ToggleCellDropdown Int Int
    | SelectDropdownParent Int Int String (rowData -> ( String, Maybe String ) -> rowData)
    | ViewDropdownChildren Int Int String (rowData -> ( String, Maybe String ) -> rowData)
    | SelectDropdownChild Int Int String String (rowData -> ( String, Maybe String ) -> rowData)
    | UpdateSearchText String
    | UpdateColumnFilterText Int String
    | SwitchColumnCheckboxFilter Int (Maybe Bool)
    | ToggleRowCheckbox Int
    | ToggleAllRowsCheckboxes
    | ToggleChooseVisibleColumnsUi
    | ToggleColumnVisibility Int
    | SortRows (Column rowData)
    | TableClick
