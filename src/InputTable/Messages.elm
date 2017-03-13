module InputTable.Messages exposing (..)

{-| This module lists the messages that may be sent by InputTable events
# Definition
@docs TableMsg
-}

import InputTable.Model exposing (..)


{-| TableMsg union type contains all messages sent by InputTable events
-}
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
    | ToggleVisibleRowsCheckboxes (List (Row rowData))
    | ToggleChooseVisibleColumnsUi
    | ToggleColumnVisibility Int
    | SortRows (Column rowData)
    | TableClick
    | PreviousPage
    | NextPage Int
