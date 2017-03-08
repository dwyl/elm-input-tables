module MainView exposing (view)

import Html
import MainMessages
import Table.View


view model =
    Html.map MainMessages.Table (Table.View.view model.tableState)
