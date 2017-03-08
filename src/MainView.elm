module MainView exposing (view)

import Table.View


view model =
    Table.View.view model.tableState
