module Moody exposing (..)

{-| Compare the behaviour of `send` and `sendImmediately` in communicating with
a moody server.

Periodically sends messages to the echo endpoint with both `send` and
`sendImmediately`. Compare the behaviour of both methods of sending when the
endpoint starts late or drops out while the Elm application is running.

-}

import Set exposing (Set)
import Html as H
import Html.Attributes as HA
import Time exposing (Time)


--

import WebSocket exposing (Message(..))


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
    { sent : List ( String, String )
    , received : Set String
    }


init : ( Model, Cmd Msg )
init =
    { sent = [], received = Set.empty } ! []



-- UPDATE


type Msg
    = Response WebSocket.Message
    | Tick Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            let
                ( queued, immediate ) =
                    ( "Queued (" ++ toString time ++ ")"
                    , "Immediate (" ++ toString time ++ ")"
                    )
            in
                { model | sent = model.sent ++ [ ( queued, immediate ) ] }
                    ! [ WebSocket.send echoServer (WebSocket.Text queued)
                      , WebSocket.sendImmediately echoServer (WebSocket.Text immediate)
                      ]

        Response message ->
            { model
                | received =
                    case message of
                        WebSocket.Text text ->
                            Set.insert text model.received

                        _ ->
                            model.received
            }
                ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ WebSocket.listen echoServer Response
        , Time.every (500 * Time.millisecond) Tick
        ]



-- VIEW


view : Model -> H.Html Msg
view model =
    H.table
        [ HA.style [ ( "width", "100%" ) ] ]
        [ H.thead
            []
            [ H.tr
                []
                [ H.th [] [ "Queued - Sent" |> H.text ]
                , H.th [] [ "Queued - Received" |> H.text ]
                , H.th [] [ "Immediate - Sent" |> H.text ]
                , H.th [] [ "Immediate - Received" |> H.text ]
                ]
            ]
        , H.tbody
            []
            (List.indexedMap
                (\index ( queued, immediate ) ->
                    H.tr
                        []
                        (List.concatMap
                            (\name ->
                                [ H.td [ HA.align "center" ]
                                    [ H.text name ]
                                , H.td [ HA.align "center" ]
                                    [ H.text <|
                                        if Set.member name model.received then
                                            "✓"
                                        else
                                            "—"
                                    ]
                                ]
                            )
                            [ queued, immediate ]
                        )
                )
                model.sent
            )
        ]
