module Main exposing (main)

import Array
import Browser
import Content
import Eth.Utils
import Ports
import Random
import Time
import Types exposing (Flags, Model, Msg)
import Update exposing (update)
import View exposing (view)
import View3d


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( mesh, box ) =
            View3d.decodeTexture flags.texture

        contract =
            Eth.Utils.unsafeToAddress flags.contract
    in
    ( { data = []
      , turn = 0
      , mesh = mesh
      , box = box
      , view = Types.ViewHome
      , small = flags.width < 700
      , contract = contract
      , address = Nothing
      , loot = Array.empty
      , index = 0
      , claim = ""
      , claimTx = Nothing
      , hasWallet = flags.hasWallet
      }
    , Content.gen
        |> Random.generate Types.RandCb
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    [ Time.every 30 (always Types.Tick)
    , Ports.connectResponse Types.ConnectCb
    , Ports.claimResponse Types.ClaimCb
    , Ports.clearWallet (always Types.ClearWallet)
    ]
        |> Sub.batch
