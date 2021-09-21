module View3d exposing (decodeTexture, view)

import Angle
import Array
import BoundingBox3d exposing (BoundingBox3d)
import Camera3d
import Direction3d
import Element exposing (Element, el, fill, height, width)
import Length exposing (Meters)
import Luminance
import Maybe.Extra exposing (unwrap)
import Obj.Decode exposing (ObjCoordinates)
import Pixels
import Point3d
import Quantity
import Scene3d
import Scene3d.Light
import Scene3d.Material
import Scene3d.Mesh exposing (Textured)
import SketchPlane3d
import TriangularMesh
import Viewpoint3d


getPoints :
    TriangularMesh.TriangularMesh
        { position : Point3d.Point3d Meters ObjCoordinates
        , uv : ( Float, Float )
        }
    -> List (Point3d.Point3d Meters ObjCoordinates)
getPoints =
    TriangularMesh.vertices >> Array.toList >> List.map .position


decodeTexture : String -> ( Textured ObjCoordinates, BoundingBox3d Meters ObjCoordinates )
decodeTexture =
    Obj.Decode.decodeString
        Length.meters
        Obj.Decode.texturedTriangles
        >> Result.toMaybe
        >> unwrap
            ( Scene3d.Mesh.texturedFacets TriangularMesh.empty
            , BoundingBox3d.singleton Point3d.origin
            )
            (\mesh ->
                ( Scene3d.Mesh.texturedFacets mesh
                , case getPoints mesh of
                    first :: rest ->
                        BoundingBox3d.hull first rest

                    [] ->
                        BoundingBox3d.singleton Point3d.origin
                )
            )


view : Int -> Textured ObjCoordinates -> BoundingBox3d Meters ObjCoordinates -> Element msg
view n mesh boundingBox =
    let
        color =
            --Scene3d.Material.matte Color.darkRed
            Scene3d.Material.emissive Scene3d.Light.sunlight (Luminance.nits 100)

        { minX, maxX, minY, maxY, minZ, maxZ } =
            BoundingBox3d.extrema boundingBox

        distance =
            List.map Quantity.abs [ minX, maxX, minY, maxY, minZ, maxZ ]
                |> List.foldl Quantity.max Quantity.zero
                --|> Quantity.multiplyBy 2
                --|> Quantity.multiplyBy (2 - zoom)
                |> Quantity.multiplyBy 4

        camera =
            Camera3d.perspective
                { viewpoint =
                    --Viewpoint3d.orbitZ
                    --{ focalPoint = BoundingBox3d.centerPoint boundingBox
                    --, azimuth = Angle.degrees -90
                    --, elevation = Angle.degrees 90
                    --, distance = distance
                    --}
                    Viewpoint3d.orbit
                        { focalPoint = BoundingBox3d.centerPoint boundingBox
                        , azimuth = Angle.degrees -90
                        , elevation = Angle.degrees 90
                        , distance = distance
                        , groundPlane =
                            SketchPlane3d.through Point3d.origin
                                (Direction3d.xz (Angle.degrees (toFloat n)))
                        }
                , verticalFieldOfView = Angle.degrees 20
                }

        entity =
            Scene3d.mesh color mesh
    in
    Scene3d.sunny
        { upDirection = Direction3d.z
        , sunlightDirection = Direction3d.negativeZ
        , shadows = False
        , camera = camera
        , dimensions = ( Pixels.int 300, Pixels.int 300 )
        , background = Scene3d.transparentBackground
        , clipDepth = Length.meters 0
        , entities = [ entity ]
        }
        |> Element.html
        |> el [ height fill, width fill ]
