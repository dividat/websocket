module Main exposing (..)

import Html as H
import Html.Events as HE


--

import WebSocket exposing (Message(..))


--

import Binary


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


echoServer : String
echoServer =
    "ws://127.0.0.1:9000"



-- MODEL


type alias Model =
    String


init : ( Model, Cmd Msg )
init =
    "" ! []



-- UPDATE


type Msg
    = Response WebSocket.Message
    | Send WebSocket.Message


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Send msg ->
            model ! [ WebSocket.send echoServer msg ]

        Response msg ->
            let
                msg_ =
                    msg
                        |> Debug.log "Response"
            in
                model ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen echoServer Response



-- VIEW


view : Model -> H.Html Msg
view model =
    H.div []
        [ H.button [ HE.onClick <| Send (Text "Hello") ] [ H.text "Send Hello" ]
        , H.button [ HE.onClick <| Send (Binary <| Binary.zeros 10) ] [ H.text "Beep" ]
        ]
