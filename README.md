# Elm Input Table

## What is it?
This is a UI table that allows the user to input data into the table through text and (sub)dropdown inputs.
It can be used when you want to allow the user to view and manipulate many pieces of data from the same view.

To try it out, clone the [repo](https://github.com/dwyl/elm-input-tables) and run `npm start` from the root directory.

## Installation

`elm-package install dwyl/elm-input-tables`

## Setup
There are 5 steps to integrating this component into your app
### 1. Add the tableState as property on your model type and pass it a type that models the data on a row eg:
```elm

import InputTable.Model

type alias Model =
    { tableState : Table.Model.TableState MyRowDataType
    , unrelatedProperty : String
    }

type alias MyRowDataType =
  { stringProp : String
  , stringInput : String
  , checkboxInput : Bool
  , dropDownInput : String
  , subDropdownInput : ( String, Maybe String )
  }

```

### 2. Set the initial table state
This example shows many column types so it is more complex. You can remove columns for simplicity.
```elm

import InputTable.Model exposing (..)

initialModel =
    { tableState : initialTableState
    , unrelatedProperty : "xyz"
    }

tableState : TableState RowData
tableState =
    { searchText = ""
    , showVisibleColumnsUi = False
    , sorting = NoSorting
    , externalFilter = (\r -> True)
    , pageSize = Just 10
    , currentPage = 1
    , columns = initialColumns
    , rows = initialRows
    }


initialColumns =
    [ Column 1 "display column" True (DisplayColumn (DisplayColumnProps .stringProp ""))
    , Column 4 "category" True (DropdownColumn (DropdownColumnProps .dropDownInput (\d v -> { d | dropDownInput = v }) "" [ "category 1", "category 2", "category 3" ]))
    , Column 5
        "subDropdownInput"
        True
        (SubDropdownColumn
            (SubDropdownColumnProps
                .subDropdownInput
                (\d ( val, sub ) -> { d | subDropdownInput = ( val, sub ) })
                ""
                [ { parent = "parent 1", childHeader = Nothing, children = [ "child 1", "child 2" ] }
                , { parent = "parent 2", childHeader = Nothing, children = [] }
                , { parent = "parent 3", childHeader = Just "Choose one of: ", children = [ "child 1", "child 2", "child 3" ] }
                ]
                Nothing
                Nothing
            )
        )
    , Column 6 "text input column " True (TextColumn (TextColumnProps .stringInput (\d v -> { d | stringInput = v }) "" False))
    , Column 7 "bool input column " True (CheckboxColumn (CheckboxColumnProps .checkboxInput (\d _ -> { d | checkboxInput = not d.checkboxInput }) Nothing))
    ]


initialRows =
    List.range 1 15
        |> List.map makeRow


makeRow id =
    { id = id
    , data =
        { stringProp = "string prop " ++ (toString id)
        , stringInput = "string input " ++ (toString id)
        , checkboxInput = True
        , dropDownInput = "category 1"
        , subDropdownInput = ( "parent 1", Just "child 1" )
        }
    , checked = False
    }
```

### 3. Add the table Message as branch to your Main Message union type

```elm
import InputTable.Messages exposing (..)

type Msg
   = Table (TableMsg RowData)
   | MyOtherMessage
   | Etc
```

### 4. Add add a branch to your update that handles the TableMessages

```elm
import InputTable.Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Table tableMsg ->
            ( { model | tableState = InputTable.Update.update tableMsg model.tableState }, Cmd.none )
        MyOtherMessage ->
          ...
```

### 5. Add the table view somewhere in your view code
```elm
import InputTable.View

div
    []
    [ (Html.map MainMessages.Table (InputTable.View.view model.tableState))
    ]
```
