module InputTable.Model exposing (..)

{-| This module specifies the model for the InputTable
@docs TableState, CheckboxColumnProps, Column, ColumnSubType, DisplayColumnProps, DropdownColumnProps, Row, Sorting, SubDropdownColumnProps, SubDropdownOptionProps, TextColumnProps
-}


{-| Holds the state of the table
-}
type alias TableState rowData =
    { columns : List (Column rowData)
    , rows : List (Row rowData)
    , searchText : String
    , showVisibleColumnsUi : Bool {- specifies whether to show controls to toggle columns -}
    , sorting : Sorting
    , externalFilter : Row rowData -> Bool
    , pageSize : Maybe Int {- number of rows per page, if nothing then all rows are displayed -}
    , currentPage : Int
    }


{-| Possible types of sorting on table, with Ints being column ids.
-}
type Sorting
    = NoSorting
    | Asc Int {- int represents column id -}
    | Desc Int


{-| Models a column on the table
-}
type alias Column rowData =
    { id : Int
    , name : String
    , visible : Bool
    , subType : ColumnSubType rowData {- contains options specific to column sub type -}
    }


{-| Defines a column subtype and holds the properties specific to that subtype
-}
type ColumnSubType rowData
    = DisplayColumn (DisplayColumnProps rowData)
    | TextColumn (TextColumnProps rowData)
    | DropdownColumn (DropdownColumnProps rowData)
    | SubDropdownColumn (SubDropdownColumnProps rowData)
    | CheckboxColumn (CheckboxColumnProps rowData)


{-| Specifies state of a display column
-}
type alias DisplayColumnProps rowData =
    { get : rowData -> String {- function to get data from row data -}
    , filter : String {- filter string -}
    }


{-| Specifies state of a text input column
-}
type alias TextColumnProps rowData =
    { get : rowData -> String
    , set : rowData -> String -> rowData {- function to set data on row data -}
    , filter : String
    , isTextArea : Bool {- Flag to set to text area, otherwise regular input -}
    }


{-| Specifies state of a dropdown input column
-}
type alias DropdownColumnProps rowData =
    { get : rowData -> String
    , set : rowData -> String -> rowData
    , filter : String
    , options : List String {- dropdown options in select element -}
    }


{-| Specifies state of a subdropdown input column (dropdown with child dropdowns)
-}
type alias SubDropdownColumnProps rowData =
    { get : rowData -> ( String, Maybe String )
    , set : rowData -> ( String, Maybe String ) -> rowData
    , filter : String
    , options : List SubDropdownOptionProps
    , focussedRowId : Maybe Int
    , focussedOption : Maybe String
    }


{-| Specifies state of a child dropdown within a subdropdown parent)
-}
type alias SubDropdownOptionProps =
    { parent : String {- parent level dropdown text -}
    , childHeader : Maybe String {- header a top of children list text -}
    , children : List String {- list of children -}
    }


{-| Specifies state of a checkbox input column
-}
type alias CheckboxColumnProps rowData =
    { get : rowData -> Bool
    , set : rowData -> Bool -> rowData
    , filter : Maybe Bool
    }


{-| Holds row state, with component user specifying rowData structure
-}
type alias Row rowData =
    { id : Int
    , data : rowData {- can be whatever data structure you specify, it's up to you how to get/set data from columns -}
    , checked : Bool
    }
