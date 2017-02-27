module TableView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_)
import MainModel exposing (..)


view : Model -> Html msg
view model =
    div [ class "table-responsive" ]
        [ input [ placeholder "Search" ] []
        , table [ class "table table-condensed table-bordered" ]
            [ thead []
                (viewHeaders model)
            , tbody []
                (List.map (viewTableRow model.inputColumns) model.rows)
            ]
        ]


viewHeaders model =
    [ tr [] (checkboxHeader :: (viewContentHeaders model) ++ (viewInputHeaders model)) ]


checkboxHeader =
    th [] [ checkbox ]


checkbox =
    input [ type_ "checkbox" ] []


viewContentHeaders model =
    List.map viewContentHeader model.contentColumns


viewContentHeader : ContentColumn -> Html msg
viewContentHeader column =
    th []
        [ div [] [ text column.name ]
        , input [ placeholder "Filter" ] []
        ]


viewInputHeaders model =
    List.map viewInputHeader model.inputColumns


viewInputHeader column =
    th []
        [ div [] [ text column.name ]
        , input [ placeholder "Filter" ] []
        ]


viewTableRow : List InputColumn -> Row -> Html msg
viewTableRow inputColumns row =
    tr [] ((checkboxCell row) :: (viewContentCells row) ++ (viewInputCells inputColumns row))


checkboxCell row =
    td []
        [ checkbox
        , span [] [ text (toString row.id) ]
        ]


viewContentCells row =
    List.map viewContentCell row.contentCells


viewContentCell : ContentCell -> Html msg
viewContentCell cell =
    td [] [ text cell.value ]


viewInputCells inputColumns row =
    List.map2 viewInputCell inputColumns row.inputCells


viewInputCell inputColumn cell =
    let
        viewOption val =
            option [] [ text val ]
    in
        case inputColumn.options of
            NoOptions ->
                td []
                    [ input [ type_ "text" ] []
                    ]

            OptionsList options ->
                td []
                    [ select [ type_ "text" ]
                        (List.map viewOption options)
                    ]
