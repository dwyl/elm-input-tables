module Table.ViewCell exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onMouseEnter, onWithOptions)
import Json.Decode as Json
import Table.Model exposing (..)
import Table.Messages exposing (..)


view row column =
    if column.visible then
        Just
            ((case column.subType of
                DisplayColumn props ->
                    td [ class "table-cell" ]
                        [ text (props.get row.data) ]

                TextColumn props ->
                    td [ class "table-cell table-cell--control" ]
                        [ (if props.isTextArea then
                            textarea
                           else
                            input
                          )
                            [ onInput (SetCellValue props.set row.id)
                            , value (props.get row.data)
                            ]
                            []
                        ]

                DropdownColumn props ->
                    let
                        viewOption optionsValue =
                            option [ selected (optionsValue == (props.get row.data)) ] [ text optionsValue ]
                    in
                        td [ class "table-cell table-cell--control" ]
                            [ select
                                [ class "table-cell__control"
                                , onInput (SetCellValue props.set row.id)
                                ]
                                (List.map viewOption props.options)
                            ]

                SubDropdownColumn props ->
                    let
                        ( choice, subChoice ) =
                            props.get row.data

                        buttonText =
                            subChoice
                                |> Maybe.map (\sub -> choice ++ ": " ++ sub)
                                |> Maybe.withDefault choice

                        optionList =
                            case props.focussedRowId of
                                Nothing ->
                                    text ""

                                Just rowId ->
                                    if rowId == row.id then
                                        ul
                                            [ class "table-cell__menu" ]
                                            (List.map viewOption props.options)
                                    else
                                        text ""

                        viewOption { parent, childHeader, children } =
                            if List.isEmpty children then
                                li
                                    [ class "table-cell__menu-item"
                                    , onClick (SelectDropdownParent row.id column.id parent props.set)
                                    ]
                                    [ text parent ]
                            else
                                (li
                                    [ class "table-cell__menu-item table-cell__menu-item--with-children"
                                    , onMouseEnter (ViewDropdownChildren row.id column.id parent props.set)
                                    , onClick (SelectDropdownParent row.id column.id parent props.set)
                                    ]
                                    [ text parent
                                    , (case props.focussedOption of
                                        Nothing ->
                                            text ""

                                        Just option ->
                                            if option == parent then
                                                let
                                                    childHeaderLi =
                                                        case childHeader of
                                                            Just headerString ->
                                                                li [ class "table-cell__menu-item" ] [ text headerString ]

                                                            Nothing ->
                                                                text ""
                                                in
                                                    ul
                                                        [ class "table-cell__menu table-cell__menu--sub"
                                                        ]
                                                        (childHeaderLi :: List.map (viewSubChoice parent) children)
                                            else
                                                text ""
                                      )
                                    ]
                                )

                        viewSubChoice parent child =
                            li
                                [ class "table-cell__menu-item"
                                , onClickNoPropagate (SelectDropdownChild row.id column.id parent child props.set)
                                ]
                                [ text child ]
                    in
                        td [ class "table-cell table-cell--control" ]
                            [ a [ class "table-cell__control", onClickNoPropagate (ToggleCellDropdown row.id column.id) ]
                                [ text buttonText, span [ class "caret" ] [] ]
                            , optionList
                            ]

                CheckboxColumn props ->
                    td [ class "table-cell table-cell--control" ]
                        [ label [ class "table-cell__checkbox-label" ]
                            [ input
                                [ type_ "checkbox"
                                , checked (props.get row.data)
                                , onClick (SetBoolCellValue props.set row.id)
                                ]
                                []
                            ]
                        ]
             )
            )
    else
        Nothing


onClickNoPropagate msg =
    onWithOptions "click"
        { stopPropagation = True, preventDefault = False }
        (Json.succeed msg)
