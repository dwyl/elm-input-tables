module Main exposing (..)

import Html
import MainMessages exposing (..)
import MainModel exposing (..)
import MainUpdate
import MainView


initialModel : Model
initialModel =
    { columns =
        [ Column 1 "title" .title "" True NoColumnInput
        , Column 2 "author" .author "" True NoColumnInput
        , Column 3 "Review Count" .reviewCount "" True NoColumnInput
        , Column 4 "notes" .notes "" True (TextColumnInput (\d v -> { d | notes = v }))
        , Column 5 "category" .category "" True (DropdownColumnInput (\d v -> { d | category = v }) [ "The Doors", "Nina Simone", "Curtis Reading" ])
        , Column 6 "decision" .decision "" True (DropdownColumnInput (\d v -> { d | decision = v }) [ "bonobos", "chimps", "orangutans" ])
        ]
    , rows = initialRows
    , searchText = ""
    , showVisibleColumnsUi = True
    , sorting = NoSorting
    }


initialRows =
    List.range 1 100
        |> List.map makeRow


makeRow id =
    { id = id
    , data =
        { title = "title " ++ (toString id)
        , author = makeAuthor id
        , reviewCount = "reviewCount " ++ (toString id)
        , notes = "notes " ++ (toString id)
        , category = "category " ++ (toString id)
        , decision = "decision " ++ (toString id)
        }
    , checked = False
    }


makeAuthor id =
    if id % 3 == 0 then
        "Rory Campbell"
    else if id % 3 == 1 then
        "Conor Campbell"
    else
        "Naaz Ahmed"


row1 =
    { id = 1
    , data =
        { title = "title 1"
        , author = "author 1"
        , reviewCount = "reviewCount 1"
        , notes = "notes 1"
        , category = "category 1"
        , decision = "decision 1"
        }
    , checked = False
    }


row2 =
    { id = 2
    , data =
        { title = "title 2"
        , author = "author 2"
        , reviewCount = "reviewCount 2"
        , notes = "notes 2"
        , category = "category 2"
        , decision = "decision 2"
        }
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
