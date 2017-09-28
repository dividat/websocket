module Main exposing (..)

import Html as H
import Html.Events as HE


--

import WebSocket


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
    | Send String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Send msg ->
            model ! [ WebSocket.send echoServer msg ]

        Response msg ->
            case msg of
                WebSocket.Binary buffer ->
                    let
                        msg_ =
                            buffer
                                |> Binary.length
                                |> Debug.log "binary"
                    in
                        model ! []

                WebSocket.Text msg ->
                    msg ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen echoServer Response



-- VIEW


view : Model -> H.Html Msg
view model =
    H.div []
        [ H.button [ HE.onClick <| Send "Hello" ] [ H.text "Hello" ]
        ]
