module Table.Messages exposing (..)

import Table.Model exposing (..)


type TableMsg rowData
    = SetCellValue (rowData -> String -> rowData) Int String
    | SetBoolCellValue (rowData -> Bool -> rowData) Int
    | ToggleCellDropdown Int Int
    | SelectDropdownParent Int Int String (rowData -> ( String, Maybe String ) -> rowData)
    | ViewDropdownChildren Int Int String (rowData -> ( String, Maybe String ) -> rowData)
    | SelectDropdownChild Int Int String String (rowData -> ( String, Maybe String ) -> rowData)
    | SetSearchText String
    | SetColumnFilterText Int String
    | SwitchColumnCheckboxFilter Int (Maybe Bool)
    | ToggleRowCheckbox Int
    | ToggleAllRowsCheckboxes (List (Row rowData))
    | ToggleChooseVisibleColumnsUi
    | ToggleColumnVisibility Int
    | SortRows (Column rowData)
    | TableClick
    | PreviousPage
    | NextPage Int
