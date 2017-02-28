module Main exposing (..)

import Html
import MainMessages exposing (..)
import MainModel exposing (..)
import MainUpdate
import MainView


initialModel : Model
initialModel =
    { columns =
        [ Column 1 "content col 1 name" "" NoOptions True NoColumnInput
        , Column 2 "content col 2 name" "" NoOptions True NoColumnInput
        , Column 3 "content col 3 name" "" NoOptions True NoColumnInput
        , Column 4 "input col 1 name" "" NoOptions True TextColumnInput
        , Column 5 "input col 2 name" "" (OptionsList [ "The Doors", "Nina Simone", "Curtis Reading" ]) True DropdownColumnInput
        , Column 6 "input col 3 name" "" (OptionsList [ "bonobos", "chimps", "orangutans" ]) True DropdownColumnInput
        ]
    , rows = initialRows
    , searchText = ""
    , showVisibleColumnsUi = True
    }


initialRows =
    [ row1, row2 ]


row1 =
    { id = 1
    , cells =
        [ ContentCell 1 "cel val 1"
        , ContentCell 2 "cel val 2"
        , ContentCell 3 "cel val 3"
        , ContentCell 4 "cel val 1"
        , ContentCell 5 "cel val 2"
        , ContentCell 6 "cel val 3"
        ]
    , checked = False
    }


row2 =
    { id = 2
    , cells =
        [ ContentCell 1 "cel val 4"
        , ContentCell 2 "cel val 5"
        , ContentCell 3 "cel val 6"
        , ContentCell 4 "cel val 1"
        , ContentCell 5 "cel val 2"
        , ContentCell 6 "cel val 3"
        ]
    , checked = False
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- MESSAGES
-- VIEW


view : Model -> Html.Html Msg
view model =
    MainView.view model



-- UPDATE


update =
    MainUpdate.update



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
