module Types exposing (Flags, Meta, Model, Msg(..), Nft, View(..))

import Array exposing (Array)
import BoundingBox3d exposing (BoundingBox3d)
import Eth.Types exposing (Address, TxHash)
import Json.Decode exposing (Value)
import Length exposing (Meters)
import Obj.Decode exposing (ObjCoordinates)
import Scene3d.Mesh exposing (Textured)


type alias Model =
    { data : List Nft
    , turn : Int
    , mesh : Textured ObjCoordinates
    , box : BoundingBox3d Meters ObjCoordinates
    , view : View
    , small : Bool
    , contract : Address
    , address : Maybe Address
    , loot : Array String
    , index : Int
    , claim : String
    , claimTx : Maybe TxHash
    , hasWallet : Bool
    , connectInProg : Bool
    , claimInProg : Bool
    }


type alias Flags =
    { texture : String
    , width : Int
    , contract : String
    , hasWallet : Bool
    }


type alias Meta =
    { name : String
    , description : String
    , image : String
    , attributes : List ( String, String )
    }


type alias Nft =
    { id : Int
    , meta : Meta
    }


type Msg
    = Tick
    | SetView View
    | Connect
    | WConnect
    | ConnectCb Value
    | Create
    | RandCb (List ( Int, Int ))
    | Claim
    | IdUpdate String
    | ClearWallet
    | ClaimCb Value


type View
    = ViewHome
    | ViewAbout
    | ViewClaim
