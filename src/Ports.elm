port module Ports exposing (claim, claimResponse, clearWallet, connect, connectResponse, disconnect, log, wConnect)

import Json.Decode exposing (Value)


port log : String -> Cmd msg


port disconnect : () -> Cmd msg


port connect : () -> Cmd msg


port wConnect : () -> Cmd msg


port claim : Value -> Cmd msg


port connectResponse : (Value -> msg) -> Sub msg


port claimResponse : (Value -> msg) -> Sub msg


port clearWallet : (() -> msg) -> Sub msg
