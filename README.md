# Elm Input Table

## What is it?
This is a  UI table that allows the user to input data into the table through text and (sub)dropdown inputs.
It can be used when you want to allow the user to view and manipulate many pieces of data from the same view.

## Installation

## How to use it
The are 4 steps to integrating this component into your app
### 1. Add the tableState as property on your model type.
You must pass it a type that models the data on a row eg:
```elm-lang

import InputTable.Model

type alias Model =
    { tableState : Table.Model.TableState MyRowDataType
    , unrelatedPropery : String
    }

type alias MyRowDataType =
    { stringProp : String
    , boolProp : Bool
    , recordProp : {childA: String, childB: Maybe String }
    }

```

### 2. Set the initial table state
```elm-lang

import InputTable.Model exposing (Column, DisplayColumn, TextColumn, SubDropdownColumn)

initialModel =
    { tableState : initialTableState
    }

initialTableState : TableState MyRowDataType
initialTableState =
    { searchText = "" -- test in search input
    , showVisibleColumnsUi = False -- whether to display column toggles
    , sorting = NoSorting -- initial sorting (Asc/Desc columnId for sorting)
    , externalFilter = (\r -> True) -- custom filter rows
    , pageSize = Just 50 -- number of rows in a page, Nothing for no pages
    , currentPage = 1 -- starting page
    , columns = initialColumns
    , rows = initialRows
    }

    initialColumns =
    [ Column
      1
      "title"
      True
      (DisplayColumn {get:  .title, filter : ""})
    , Column 1 "program Code is now verrrry lonnggggggggg" True (TextColumn (TextColumnProps .programCode (\d v -> { d | programCode = v }) "" False))
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
type alias MyRowDataType =
    { stringProp : String
    , intProp : Int
    , listProp : List String
    }
```
