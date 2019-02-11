port module Main exposing (Model, Msg(..), init, main, toJs, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Error(..))
import Json.Decode as Decode



-- ---------------------------
-- PORTS
-- ---------------------------


port toJs : String -> Cmd msg



-- ---------------------------
-- MODEL
-- ---------------------------


type alias Model =
    { capacity : Int
    , goodsWait : Int
    , goodsValue : Int
    , numOfGene : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { capacity = 500
      , goodsWait = 20
      , goodsValue = 10
      , numOfGene = 20
      }
    , Cmd.none
    )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view ({ capacity, goodsWait, goodsValue, numOfGene } as model) =
    section []
        [ article [ class "initial-settings" ]
            [ article []
                [ h1 [] [ text "初期設定" ]
                ]
            , article [ class "knapsack-with-box-settings" ]
                [ article [ class "knapsack-setting pure-form" ]
                    [ img [ src "/images/knapsack.svg" ] []
                    , article []
                        [ label [] [ text "容量" ]
                        , input [ type_ "number", value <| String.fromInt capacity, readonly True ] []
                        ]
                    ]
                , article [ class "box-setting" ]
                    [ img [ src "/images/box.svg" ] []
                    , article [ class "pure-form" ]
                        [ article []
                            [ label [] [ text "重さ" ]
                            , input [ type_ "number", value <| String.fromInt goodsWait, readonly True ] []
                            ]
                        , article []
                            [ label [] [ text "価値" ]
                            , input [ type_ "number", value <| String.fromInt goodsValue, readonly True ] []
                            ]
                        ]
                    , article [ class "gene-setting pure-form" ]
                        [ img [ src "/images/gene.svg" ] []
                        , article []
                            [ label [] [ text "遺伝子数" ]
                            , input [ type_ "number", value <| String.fromInt numOfGene, readonly True ] []
                            ]
                        ]
                    ]
                ]
            ]
        , article []
            [ article [ class "generation" ]
                [ h1 [] [ text "第n世代" ]
                , button [ class "pure-button pure-button-primary" ] [ text "次の世代へ" ]
                ]
            , article [ class "boxs" ] <|
                List.repeat 50
                    (article [ class "box-with-label" ]
                        [ img [ src "/images/box.svg", width 60, height 60 ] []
                        , label [] [ text "w2v5" ]
                        ]
                    )
            , article [ class "genes" ] <|
                List.repeat 20
                    (article [ class "gene-with-label" ]
                        [ img [ src "/images/black-knapsack.svg", width 60, height 60 ] []
                        , label [] [ text "w2v5" ]
                        ]
                    )
            ]
        ]



-- ---------------------------
-- MAIN
-- ---------------------------


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Knapsack GA"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        }
