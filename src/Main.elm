module Main exposing (..)

import Html
import MainMessages exposing (..)
import MainModel exposing (..)
import MainUpdate
import MainView


initialModel : Model
initialModel =
    { columns =
        [ Column 1 "id" True (CheckboxColumn (CheckboxColumnConfig .selected (\d _ -> { d | selected = not d.selected }) Nothing))
        , Column 2 "title" True (DisplayColumn (DisplayColumnConfig .title ""))
        , Column 3 "author" True (DisplayColumn (DisplayColumnConfig .author ""))
        , Column 4 "Review Count" True (DisplayColumn (DisplayColumnConfig .reviewCount ""))
        , Column 5 "notes" True (TextColumn (TextColumnConfig .notes (\d v -> { d | notes = v }) ""))
        , Column 6 "category" True (DropdownColumn (DropdownColumnConfig .category (\d v -> { d | category = v }) "" [ "The Doors", "Nina Simone", "Curtis Reading" ]))
        , Column 7 "decision" True (DropdownColumn (DropdownColumnConfig .decision (\d v -> { d | decision = v }) "" [ "bonobos", "chimps", "orangutans" ]))
        ]
    , rows = initialRows
    , searchText = ""
    , showVisibleColumnsUi = True
    , sorting = NoSorting
    }


initialRows =
    List.range 1 5
        |> List.map makeRow


makeRow id =
    { id = id
    , data =
        { selected = False
        , title = "title " ++ (toString id)
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
