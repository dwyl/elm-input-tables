module Main exposing (..)

import Html
import MainMessages exposing (..)
import MainModel exposing (..)
import MainUpdate
import MainView


initialModel : Model
initialModel =
    { tableState = tableState }


tableState : TableState
tableState =
    { columns =
        [ Column 2 "title" True (DisplayColumn (DisplayColumnProps .title ""))
        , Column 3 "author" True (DisplayColumn (DisplayColumnProps .author ""))
          -- , Column 4 "Review Count" True (DisplayColumn (DisplayColumnProps .reviewCount ""))
        , Column 5 "program Code" True (TextColumn (TextColumnProps .programCode (\d v -> { d | programCode = v }) "" False))
        , Column 8
            "decision"
            True
            (SubDropdownColumn
                (SubDropdownColumnProps
                    .decision
                    (\d ( val, sub ) -> { d | decision = ( val, sub ) })
                    ""
                    [ ( "Pending", [] )
                    , ( "Advance", [ "Rework", "Final" ] )
                    , ( "Accept", [ "Oral", "Poster", "Workshop" ] )
                    , ( "Withdraw", [] )
                    , ( "Reject", [] )
                    ]
                    Nothing
                    Nothing
                )
            )
          -- , Column 6 "notes" True (TextColumn (TextColumnProps .notes (\d v -> { d | notes = v }) "" True))
        , Column 1 "C.O.I" True (CheckboxColumn (CheckboxColumnProps .conflictOfInterest (\d _ -> { d | conflictOfInterest = not d.conflictOfInterest }) Nothing))
        , Column 7 "category" True (DropdownColumn (DropdownColumnProps .category (\d v -> { d | category = v }) "" [ "The Doors", "Nina Simone", "Curtis Reading" ]))
        ]
    , rows = initialRows
    , searchText = ""
    , showVisibleColumnsUi = True
    , sorting = NoSorting
    }


initialRows =
    List.range 1 50
        |> List.map makeRow


makeRow id =
    { id = id
    , data =
        { conflictOfInterest = False
        , title = "title " ++ (toString id)
        , author = makeAuthor id
        , reviewCount = "reviewCount " ++ (toString id)
        , notes = "notes " ++ (toString id)
        , programCode = makeProgramCode id
        , category = "The Doors"
        , decision = ( "Pending", Nothing )
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


makeProgramCode id =
    if id % 4 == 0 then
        "P" ++ (toString id)
    else if id % 4 == 1 then
        "O" ++ (toString id)
    else if id % 4 == 2 then
        "I" ++ (toString id)
    else
        "T" ++ (toString id)


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
