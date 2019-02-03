port module Main exposing (Model, Msg(..), add1, init, main, toJs, update, view)

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
    { counter : Int
    , serverMessage : String
    }


init : Int -> ( Model, Cmd Msg )
init flags =
    ( { counter = flags, serverMessage = "" }, Cmd.none )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = Inc
    | Set Int
    | TestServer
    | OnServerResponse (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Inc ->
            ( add1 model, toJs "Hello Js" )

        Set m ->
            ( { model | counter = m }, toJs "Hello Js" )

        TestServer ->
            let
                expect =
                    Http.expectJson OnServerResponse (Decode.field "result" Decode.string)
            in
            ( model
            , Http.get { url = "/test", expect = expect }
            )

        OnServerResponse res ->
            case res of
                Ok r ->
                    ( { model | serverMessage = r }, Cmd.none )

                Err err ->
                    ( { model | serverMessage = "Error: " ++ httpErrorToString err }, Cmd.none )


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        BadUrl _ ->
            "BadUrl"

        Timeout ->
            "Timeout"

        NetworkError ->
            "NetworkError"

        BadStatus _ ->
            "BadStatus"

        BadBody s ->
            "BadBody: " ++ s


{-| increments the counter

    add1 5 --> 6

-}
add1 : Model -> Model
add1 model =
    { model | counter = model.counter + 1 }



-- ---------------------------
-- VIEW
-- ---------------------------
-- img [ src "/images/logo.png" ] []


view : Model -> Html Msg
view model =
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
                        , input [ type_ "number", value "500", readonly True ] []
                        ]
                    ]
                , article [ class "box-setting" ]
                    [ img [ src "/images/box.svg" ] []
                    , article [ class "pure-form" ]
                        [ article []
                            [ label [] [ text "重さ" ]
                            , input [ type_ "number", value "20", readonly True ] []
                            ]
                        , article []
                            [ label [] [ text "価値" ]
                            , input [ type_ "number", value "10", readonly True ] []
                            ]
                        ]
                    , article [ class "gene-setting pure-form" ]
                        [ img [ src "/images/gene.svg" ] []
                        , article []
                            [ label [] [ text "遺伝子数" ]
                            , input [ type_ "number", value "20", readonly True ] []
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


main : Program Int Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Elm 0.19 starter"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        }
