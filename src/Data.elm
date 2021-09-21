module Data exposing (triptych)

import Base64
import BigInt
import Contracts.Terraloot
import DataUrl
import DataUrl.Data
import Eth
import Eth.Types exposing (Address)
import Http
import Json.Decode as JD exposing (Decoder)
import Maybe.Extra exposing (unwrap)
import Random
import Task exposing (Task)
import Time
import Types exposing (Meta, Nft)


triptych : String -> Address -> Task Http.Error (List Nft)
triptych provider address =
    Time.now
        |> Task.map
            (Time.posixToMillis
                >> Random.initialSeed
                >> Random.step (Random.list 3 (Random.int 0 9999))
                >> Tuple.first
            )
        |> Task.andThen
            (List.sort
                >> List.map
                    (\n ->
                        BigInt.fromInt n
                            |> Contracts.Terraloot.tokenURI address
                            |> Eth.call provider
                            |> Task.andThen
                                (DataUrl.fromString
                                    >> Maybe.andThen
                                        (DataUrl.data
                                            >> DataUrl.Data.toString
                                            >> Base64.toString
                                        )
                                    >> Maybe.andThen
                                        (JD.decodeString decodeMeta
                                            >> Result.toMaybe
                                        )
                                    >> unwrap
                                        (Task.fail (Http.BadBody "url fail"))
                                        (\meta ->
                                            { id = n, meta = meta }
                                                |> Task.succeed
                                        )
                                )
                    )
                >> Task.sequence
            )


decodeMeta : Decoder Meta
decodeMeta =
    JD.map4 Meta
        (JD.field "name" JD.string)
        (JD.field "description" JD.string)
        (JD.field "image" JD.string)
        (JD.map2 Tuple.pair
            (JD.field "trait_type" JD.string)
            (JD.field "value" JD.string)
            |> JD.list
            |> JD.field "attributes"
        )
