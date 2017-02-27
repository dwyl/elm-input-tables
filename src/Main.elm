module Main exposing (..)

import Html
import MainModel exposing (..)
import MainView


initialModel : Model
initialModel =
    { contentColumns =
        [ ContentColumn 1 "col 1 name"
        , ContentColumn 2 "col 2 name"
        , ContentColumn 3 "col 3 name"
        ]
    , inputColumns =
        [ InputColumn 1 "col 1 name" NoOptions
        , InputColumn 2 "col 2 name" (OptionsList [ "The Doors", "Nina Simone", "Curtis Reading" ])
        , InputColumn 3 "col 3 name" (OptionsList [ "bonobos", "chimps", "orangutans" ])
        ]
    , rows = initialRows
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
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- MESSAGES


type Msg
    = Increment
    | Decrement



-- VIEW


view : Model -> Html.Html Msg
view model =
    MainView.view model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



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
