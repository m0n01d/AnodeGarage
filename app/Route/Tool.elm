module Route.Tool exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import Area
import BackendTask
import Current
import Effect
import ErrorPage
import FatalError
import Head
import Html exposing (Html)
import Html.Attributes
import Html.Events as Events
import Html.Events.Extra as Events
import Json.Decode as Decode
import Length
import PagesMsg
import Power
import Quantity
import Resistance
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import UrlPath
import View
import Voltage


type alias Model =
    {}


type Msg
    = ChangedVoltage Int
    | NoOp


type alias RouteParams =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender
        { data = data
        , action = action
        , head = head
        }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( {}, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case msg of
        ChangedVoltage volts ->
            ( model, Effect.none )

        NoOp ->
            ( model, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    {}


type alias ActionData =
    {}


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams request =
    BackendTask.succeed (Server.Response.render {})


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "Tool"
    , body =
        [ Html.h2 [] [ Html.text "Tools" ]
        , viewTools model
        ]
    }


type Rho
    = Copper Float


copperRho =
    Copper (1.7 * (10 ^ -8))
        |> Debug.log "copperRho"


twelveVolts =
    Voltage.volts 12


twentyFourVolts =
    Voltage.volts 24


watts2400 : Quantity.Quantity Float Power.Watts
watts2400 =
    power (Current.amperes 200)


watts4800 : Quantity.Quantity Float Power.Watts
watts4800 =
    power (Current.amperes 200)


power current_ =
    -- elm-units version of 'P = V * I'
    current_
        |> Quantity.at twelveVolts


toAmps power_ =
    -- I = P / V
    power_
        |> Quantity.at_ twelveVolts


amps200 : Quantity.Quantity Float Current.Amperes
amps200 =
    toAmps watts2400


fromResistance (Copper rho) resistance =
    twelveVolts
        |> Quantity.at_ resistance


res (Copper rho) =
    let
        r =
            Resistance.ohms rho

        rho_ =
            Quantity.per Length.meter r
                |> Debug.log "rho_"

        -- r
        len : Length.Length
        len =
            Length.meters 1.5
                |> Debug.log "len in meters"

        area =
            Length.millimeters 16.0
                |> Debug.log "area in mm2"

        d =
            let
                l =
                    len |> Length.inMeters

                a =
                    area |> Quantity.unwrap
            in
            l
                / a
                |> Debug.log "d"
    in
    Quantity.multiplyBy (10 ^ 6 * d) r
        |> Debug.log "reesy"


xx =
    copperRho
        |> fromResistance
        |> Debug.log "xx"


viewTools model =
    Html.div []
        [ Html.div []
            [ Html.p [] [ Html.text "Resistance:" ]
            , Html.select []
                [ Html.option [] [ Html.text "Copper" ]
                ]
            ]
        , Html.div []
            [ Html.p [] [ Html.text "Voltage" ]
            , Html.input
                [ 12 |> String.fromInt |> Html.Attributes.value
                , Events.on "input" (Decode.map (PagesMsg.fromMsg << ChangedVoltage) Events.targetValueInt)
                ]
                []
            ]
        , Html.p [] [ Html.text "Current:", [ res copperRho ] |> Debug.toString |> Html.text ]
        ]


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})
