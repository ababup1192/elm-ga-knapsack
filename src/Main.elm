module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Error(..))
import Json.Decode as Decode
import Random exposing (Generator)



-- ---------------------------
-- MODEL
-- ---------------------------


type alias Gene =
    List Bool


type alias Goods =
    { weight : Int, value : Int }


type alias Model =
    { capacity : Int
    , maxGoodsWeight : Int
    , maxGoodsValue : Int
    , numOfGene : Int
    , goodsList : List Goods
    , geneList : List Gene
    }


numOfGoods =
    50


init : () -> ( Model, Cmd Msg )
init _ =
    ( { capacity = 500
      , maxGoodsWeight = 20
      , maxGoodsValue = 10
      , numOfGene = 20
      , goodsList = []
      , geneList = []
      }
    , Cmd.batch
        [ Random.generate GenerateGoodsList <| generateGoodsList 20 10
        , Random.generate GenerateGeneList <| generateGeneList 20
        ]
    )


generateGoods : Int -> Int -> Generator Goods
generateGoods maxGoodsWeight maxGoodsValue =
    Random.map2
        Goods
        (Random.int 1 maxGoodsWeight)
        (Random.int 1 maxGoodsValue)


generateGoodsList : Int -> Int -> Generator (List Goods)
generateGoodsList maxGoodsweight maxGoodsValue =
    Random.list numOfGoods <| generateGoods maxGoodsweight maxGoodsValue


generateGene : Random.Generator Gene
generateGene =
    Random.list numOfGoods (Random.int 0 1 |> Random.map (\n -> n == 1))


generateGeneList : Int -> Generator (List Gene)
generateGeneList numOfGene =
    Random.list numOfGene generateGene


sumOfGoodsList : List Goods -> Gene -> Goods
sumOfGoodsList goodsList gene =
    List.map2 Tuple.pair goodsList gene
        |> List.filter Tuple.second
        |> List.map Tuple.first
        |> List.foldl
            (\{ weight, value } goods ->
                Goods (weight + goods.weight) (value + goods.value)
            )
            (Goods 0 0)



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = GenerateGoodsList (List Goods)
    | GenerateGeneList (List Gene)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateGoodsList goodsList ->
            ( { model | goodsList = goodsList }, Cmd.none )

        GenerateGeneList geneList ->
            ( { model | geneList = geneList }, Cmd.none )



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view ({ capacity, maxGoodsWeight, maxGoodsValue, numOfGene, goodsList, geneList } as model) =
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
                            , input [ type_ "number", value <| String.fromInt maxGoodsWeight, readonly True ] []
                            ]
                        , article []
                            [ label [] [ text "価値" ]
                            , input [ type_ "number", value <| String.fromInt maxGoodsValue, readonly True ] []
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
                (goodsList
                    |> List.map
                        (\{ weight, value } ->
                            article [ class "box-with-label" ]
                                [ img [ src "/images/box.svg", width 60, height 60 ] []
                                , label [] [ text <| "w" ++ String.fromInt weight ]
                                , label [] [ text <| "v" ++ String.fromInt value ]
                                ]
                        )
                )
            , article [ class "genes" ] <|
                (geneList
                    |> List.map
                        (\gene ->
                            let
                                { weight, value } =
                                    sumOfGoodsList goodsList gene
                            in
                            article [ class "gene-with-label" ]
                                [ img [ src "/images/black-knapsack.svg", width 60, height 60 ] []
                                , label [] [ text <| "w" ++ String.fromInt weight ]
                                , label [] [ text <| "v" ++ String.fromInt value ]
                                ]
                        )
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
