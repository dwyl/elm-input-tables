module MainUpdate exposing (update)

import Table.Messages exposing (..)
import MainModel exposing (..)
import Table.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        newTableState =
            Table.Update.update msg model.tableState
    in
        ( { model | tableState = newTableState }, Cmd.none )
