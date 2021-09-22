module Update exposing (update)

import Array
import BigInt
import Content
import Contracts.Terraloot
import Eth
import Eth.Decode
import Json.Decode as JD
import Json.Encode
import Maybe.Extra exposing (unwrap)
import Ports
import Random
import Types exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Create ->
            ( model
            , Content.gen
                |> Random.generate RandCb
            )

        Claim ->
            model.claim
                |> BigInt.fromIntString
                |> unwrap ( model, Cmd.none )
                    (\v ->
                        ( { model
                            | claimInProg = True
                            , claimTx = Nothing
                          }
                        , Contracts.Terraloot.claim model.contract v
                            |> (\r ->
                                    { r
                                        | from = model.address
                                    }
                               )
                            |> Eth.toSend
                            |> Eth.encodeSend
                            |> Ports.claim
                        )
                    )

        IdUpdate str ->
            ( { model
                | claim = str
              }
            , Cmd.none
            )

        ClearWallet ->
            ( { model
                | address = Nothing
                , claimTx = Nothing
                , claim = ""
              }
            , Ports.disconnect ()
            )

        RandCb xs ->
            ( { model
                | index = 0
                , loot =
                    xs
                        |> List.indexedMap
                            (\n ( a, b ) ->
                                case n of
                                    0 ->
                                        Content.applyMagic a b Content.outfits

                                    1 ->
                                        Content.applyMagic a b Content.tools

                                    2 ->
                                        Content.applyMagic a b Content.handheldGadgets

                                    3 ->
                                        Content.applyMagic a b Content.externalGadgets

                                    4 ->
                                        Content.applyMagic a b Content.wearableGadgets

                                    5 ->
                                        Content.applyMagic a b Content.shoulderGadgets

                                    6 ->
                                        Content.applyMagic a b Content.backpacks

                                    _ ->
                                        Content.applyMagic a b Content.rigs
                            )
                        |> Array.fromList
              }
            , Cmd.none
            )

        WConnect ->
            ( model
            , Ports.wConnect ()
            )

        Connect ->
            ( { model | connectInProg = True }
            , Ports.connect ()
            )

        ClaimCb val ->
            val
                |> JD.decodeValue Eth.Decode.txHash
                |> Result.toMaybe
                |> unwrap
                    ( { model | claimInProg = False }
                    , val
                        |> Json.Encode.encode 2
                        |> Ports.log
                    )
                    (\tx ->
                        ( { model
                            | claimTx = Just tx
                            , claimInProg = False
                            , claim = ""
                          }
                        , Cmd.none
                        )
                    )

        ConnectCb res ->
            res
                |> JD.decodeValue Eth.Decode.address
                |> Result.toMaybe
                |> unwrap
                    ( { model
                        | connectInProg = False
                      }
                    , Cmd.none
                    )
                    (\address ->
                        ( { model
                            | address = Just address
                            , connectInProg = False
                          }
                        , Cmd.none
                        )
                    )

        Tick ->
            ( { model
                | turn =
                    if model.turn == 359 then
                        0

                    else
                        model.turn + 1
                , index =
                    if model.index > 40 then
                        model.index

                    else
                        model.index + 1
              }
            , Cmd.none
            )

        SetView view ->
            ( { model | view = view }
            , Cmd.none
            )
