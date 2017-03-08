module Table.ViewCell exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onMouseEnter, onWithOptions)
import Json.Decode as Json
import MainModel exposing (..)
import MainMessages exposing (..)


view row column =
    if column.visible then
        Just
            (td []
                (case column.subType of
                    DisplayColumn props ->
                        [ text (props.get row.data) ]

                    TextColumn props ->
                        [ (if props.isTextArea then
                            textarea
                           else
                            input
                          )
                            [ onInput (UpdateCellValue props.set row.id)
                            , value (props.get row.data)
                            ]
                            []
                        ]

                    DropdownColumn props ->
                        let
                            viewOption optionsValue =
                                option [ selected (optionsValue == (props.get row.data)) ] [ text optionsValue ]
                        in
                            [ select [ onInput (UpdateCellValue props.set row.id) ]
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
                                        []

                                    Just rowId ->
                                        if rowId == row.id then
                                            List.map viewOption props.options
                                        else
                                            []

                            viewOption ( choice, subChoices ) =
                                let
                                    liChildren =
                                        if List.isEmpty subChoices then
                                            [ a [ onClick (SelectDropdownParent row.id column.id choice props.set) ] [ text choice ] ]
                                        else
                                            ([ a
                                                [ onMouseEnter (ViewDropdownChildren row.id column.id choice props.set)
                                                , onClick (SelectDropdownParent row.id column.id choice props.set)
                                                ]
                                                [ text choice
                                                , i [ class "icon-arrow-right" ] []
                                                ]
                                             , ul
                                                [ style
                                                    [ ( "position", "absolute" )
                                                    , ( "z-index", "10" )
                                                    , ( "background-color", "white" )
                                                    , ( "top", "0" )
                                                    , ( "left", "95px" )
                                                    ]
                                                , class "nav nav-tabs nav-stacked"
                                                ]
                                                (case props.focussedOption of
                                                    Nothing ->
                                                        []

                                                    Just option ->
                                                        if option == choice then
                                                            List.map (viewSubChoice choice) subChoices
                                                        else
                                                            []
                                                )
                                             ]
                                            )
                                in
                                    li [ style [ ( "position", "relative" ) ] ]
                                        liChildren

                            viewSubChoice choice subChoice =
                                li [] [ a [ onClick (SelectDropdownChild row.id column.id choice subChoice props.set) ] [ text subChoice ] ]
                        in
                            [ a [ class "btn dropdown-toggle", onClickNoPropagate (ToggleCellDropdown row.id column.id) ]
                                [ text buttonText, span [ class "caret" ] [] ]
                            , ul
                                [ style
                                    [ ( "position", "absolute" )
                                    , ( "z-index", "10" )
                                    , ( "background-color", "white" )
                                    , ( "cursor", "pointer" )
                                    ]
                                , class "nav nav-tabs nav-stacked"
                                ]
                                optionList
                            ]

                    CheckboxColumn props ->
                        [ input
                            [ type_ "checkbox"
                            , checked (props.get row.data)
                            , onClick (UpdateBoolCellValue props.set row.id)
                            ]
                            []
                        ]
                )
            )
    else
        Nothing


onClickNoPropagate msg =
    onWithOptions "click"
        { stopPropagation = True, preventDefault = False }
        (Json.succeed msg)
