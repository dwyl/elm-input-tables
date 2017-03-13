module InitialData exposing (initialModel)

import InputTable.Model exposing (..)
import MainModel exposing (..)


initialModel : Model
initialModel =
    { tableState = tableState
    , decisionFilter = NoFilter
    , stageId = Nothing
    , stages = stages
    }


stages : List Stage
stages =
    [ Stage 1 "Initial Stage"
    , Stage 2 "Rework"
    , Stage 3 "Final"
    ]


tableState : TableState RowData
tableState =
    { columns =
        [ Column 2 "title" True (DisplayColumn (DisplayColumnProps .title ""))
        , Column 3 "author" True (DisplayColumn (DisplayColumnProps .author ""))
        , Column 4 "Review Count" True (DisplayColumn (DisplayColumnProps .reviewCount ""))
        , Column 5 "program Code is now verrrry lonnggggggggg" True (TextColumn (TextColumnProps .programCode (\d v -> { d | programCode = v }) "" False))
        , Column 8
            "decision"
            True
            (SubDropdownColumn
                (SubDropdownColumnProps
                    .decision
                    (\d ( val, sub ) -> { d | decision = ( val, sub ) })
                    ""
                    [ { parent = "Pending", childHeader = Nothing, children = [] }
                    , { parent = "Advance", childHeader = Just "To: ", children = [ "Rework", "Final" ] }
                    , { parent = "Accept", childHeader = Just "For: ", children = [ "Oral", "Poster", "Workshop" ] }
                    , { parent = "Withdraw", childHeader = Nothing, children = [] }
                    , { parent = "Reject", childHeader = Nothing, children = [] }
                    ]
                    Nothing
                    Nothing
                )
            )
        , Column 6 "notes" True (TextColumn (TextColumnProps .notes (\d v -> { d | notes = v }) "" True))
        , Column 1 "C.O.I" True (CheckboxColumn (CheckboxColumnProps .conflictOfInterest (\d _ -> { d | conflictOfInterest = not d.conflictOfInterest }) Nothing))
        , Column 7 "category" True (DropdownColumn (DropdownColumnProps .category (\d v -> { d | category = v }) "" [ "The Doors", "Nina Simone", "Curtis Reading" ]))
        ]
    , rows = initialRows
    , searchText = ""
    , showVisibleColumnsUi = False
    , sorting = NoSorting
    , externalFilter = (\r -> True)
    , pageSize = Just 50
    , currentPage = 1
    }


initialRows =
    List.range 1 500
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
        , stageId = 1
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
