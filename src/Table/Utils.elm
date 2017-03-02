module Table.Utils exposing (getCellVal, CellVal)

import MainModel exposing (..)


type CellVal
    = StringCellVal String
    | BoolCellVal Bool


getCellVal : RowData -> Column -> CellVal
getCellVal rowData column =
    case column.subType of
        DisplayColumn props ->
            StringCellVal (props.get rowData)

        TextColumn props ->
            StringCellVal (props.get rowData)

        DropdownColumn props ->
            StringCellVal (props.get rowData)

        CheckboxColumn props ->
            BoolCellVal (props.get rowData)
