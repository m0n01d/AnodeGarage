module Route.Tool exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

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
import PagesMsg
import Power
import Quantity
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
    Copper (1.7 * 10 ^ -8)


currentByResistance volts ohm =
    volts / ohm


twelveVolts =
    Voltage.volts 12


twentyFourVolts =
    Voltage.volts 24



-- elm-units version of 'P = V * I'


watts2400 : Quantity.Quantity Float Power.Watts
watts2400 =
    power twelveVolts (Current.amperes 200)


watts4800 : Quantity.Quantity Float Power.Watts
watts4800 =
    power twentyFourVolts (Current.amperes 200)


power =
    Quantity.at



-- I = P / V


amps =
    Quantity.at_


watts200 : Quantity.Quantity Float Current.Amperes
watts200 =
    amps twelveVolts watts2400


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
        , Html.p [] [ Html.text "Current:", [ watts200 ] |> Debug.toString |> Html.text ]
        ]


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})
