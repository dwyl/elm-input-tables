module Main exposing (..)

import Html
import MainMessages exposing (..)
import MainModel exposing (..)
import MainUpdate
import MainView


initialModel : Model
initialModel =
    { contentColumns =
        [ Column 1 "content col 1 name" "" NoOptions True
        , Column 2 "content col 2 name" "" NoOptions True
        , Column 3 "content col 3 name" "" NoOptions True
        ]
    , inputColumns =
        [ Column 1 "input col 1 name" "" NoOptions True
        , Column 2 "input col 2 name" "" (OptionsList [ "The Doors", "Nina Simone", "Curtis Reading" ]) True
        , Column 3 "input col 3 name" "" (OptionsList [ "bonobos", "chimps", "orangutans" ]) True
        ]
    , rows = initialRows
    , searchText = ""
    , showVisibleColumnsUi = True
    }


initialRows =
    [ row1, row2 ]


row1 =
    { id = 1
    , contentCells =
        [ ContentCell 1 "cel val 1"
        , ContentCell 2 "cel val 2"
        , ContentCell 3 "cel val 3"
        ]
    , inputCells =
        [ ContentCell 1 "cel val 1"
        , ContentCell 2 "cel val 2"
        , ContentCell 3 "cel val 3"
        ]
    , checked = False
    }


row2 =
    { id = 2
    , contentCells =
        [ ContentCell 1 "cel val 4"
        , ContentCell 2 "cel val 5"
        , ContentCell 3 "cel val 6"
        ]
    , inputCells =
        [ ContentCell 1 "cel val 1"
        , ContentCell 2 "cel val 2"
        , ContentCell 3 "cel val 3"
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
