module Table.Utils exposing (getCellVal, CellVal)

import MainModel exposing (..)


type CellVal
    = StringCellVal String
    | BoolCellVal Bool


getCellVal : RowData -> Column -> CellVal
getCellVal rowData column =
    case column.config of
        DisplayColumn config ->
            StringCellVal (config.get rowData)

        TextColumn config ->
            StringCellVal (config.get rowData)

        DropdownColumn config ->
            StringCellVal (config.get rowData)

        CheckboxColumn config ->
            BoolCellVal (config.get rowData)
