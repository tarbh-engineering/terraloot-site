module Img exposing (loot, metamask, sun, walletConnect)

import Array exposing (Array)
import Element exposing (Element)
import Svg exposing (Svg, clipPath, defs, ellipse, path, rect, style, svg, text, text_)
import Svg.Attributes exposing (class, cx, cy, d, fill, height, id, preserveAspectRatio, rx, ry, stroke, strokeLinecap, strokeLinejoin, viewBox, width, x, y)


get : Int -> Int -> Array String -> String
get index limit =
    Array.get index
        >> Maybe.withDefault "OOPS"
        >> (\str ->
                if limit >= String.length str then
                    str

                else
                    String.left limit str ++ "█"
           )


loot : Int -> Array String -> Svg msg
loot n xs =
    let
        title =
            if n >= 12 then
                "TL:XXXX"

            else
                String.right (12 - n) "____"
                    |> String.padLeft 4 'X'
                    |> (++) "TL:"
    in
    svg
        [ preserveAspectRatio "xMinYMin meet"
        , viewBox "0 0 350 350"
        ]
        [ defs [] [ clipPath [ id "clp" ] [ rect [ width "100%", height "100%" ] [] ] ]
        , style [] [ text "text{fill:#fff;font-family:Source Code Pro;font-size:13px}.tag{font-size:24px}ellipse{clip-path:url(#clp)}" ]
        , rect [ width "100%", height "100%", fill "#000020" ] []
        , ellipse [ cx "320", cy "320", rx "130", ry "130", fill "#c32205" ] []
        , text_ [ x "240", y "335", class "tag" ]
            [ text title
            ]
        , text_ [ x "8", y "20" ] [ get 0 n xs |> text ]
        , text_ [ x "8", y "43" ] [ get 1 n xs |> text ]
        , text_ [ x "8", y "66" ] [ get 2 n xs |> text ]
        , text_ [ x "8", y "89" ] [ get 3 n xs |> text ]
        , text_ [ x "8", y "112" ] [ get 4 n xs |> text ]
        , text_ [ x "8", y "135" ] [ get 5 n xs |> text ]
        , text_ [ x "8", y "158" ] [ get 6 n xs |> text ]
        , text_ [ x "8", y "181" ] [ get 7 n xs |> text ]
        ]


metamask : Element msg
metamask =
    svg
        [ viewBox "0 0 319 319"
        , Svg.Attributes.height "40"
        ]
        [ style [] [ text " .st1,.st6{fill:#e4761b;stroke:#e4761b;stroke-linecap:round;stroke-linejoin:round}.st6{fill:#f6851b;stroke:#f6851b} " ]
        , Svg.path [ fill "#e2761b", stroke "#e2761b", strokeLinecap "round", strokeLinejoin "round", d "m274 36-99 73 18-43z" ] []
        , Svg.path [ d "m44 36 99 74-17-44zm194 171-26 40 57 16 16-55zm-204 1 16 55 57-16-27-40z", class "st1" ] []
        , Svg.path [ d "m104 138-16 24 56 3-2-61zm111 0-39-35-1 62 56-3zM107 247l34-16-30-23zm71-16 34 16-5-39z", class "st1" ] []
        , Svg.path [ fill "#d7c1b3", stroke "#d7c1b3", strokeLinecap "round", strokeLinejoin "round", d "m212 247-34-16 3 22-1 9zm-105 0 31 15v-9l3-22z" ] []
        , Svg.path [ fill "#233447", stroke "#233447", strokeLinecap "round", strokeLinejoin "round", d "m139 194-28-9 20-9zm41 0 8-18 20 9z" ] []
        , Svg.path [ fill "#cd6116", stroke "#cd6116", strokeLinecap "round", strokeLinejoin "round", d "m107 247 5-40-32 1zm100-40 5 40 26-39zm24-45-56 3 5 29 8-18 20 9zm-120 23 20-9 8 18 5-29-56-3z" ] []
        , Svg.path [ fill "#e4751f", stroke "#e4751f", strokeLinecap "round", strokeLinejoin "round", d "m88 162 23 46v-23zm120 23-1 23 24-46zm-64-20-5 29 6 34 2-45zm31 0-3 18 1 45 7-34z" ] []
        , Svg.path [ d "m180 194-7 34 5 3 29-23 1-23zm-69-9v23l30 23 4-3-6-34z", class "st6" ] []
        , Svg.path [ fill "#c0ad9e", stroke "#c0ad9e", strokeLinecap "round", strokeLinejoin "round", d "m180 262 1-9-3-2h-38l-2 2v9l-31-15 11 9 22 16h38l23-16 11-9z" ] []
        , Svg.path [ fill "#161616", stroke "#161616", strokeLinecap "round", strokeLinejoin "round", d "m178 231-5-3h-28l-4 3-3 22 2-2h38l3 2z" ] []
        , Svg.path [ fill "#763d16", stroke "#763d16", strokeLinecap "round", strokeLinejoin "round", d "m278 114 9-41-13-37-96 71 37 31 52 16 12-14-5-4 8-7-6-5 8-6zM32 73l8 41-5 4 8 6-6 5 8 7-5 4 11 14 53-16 37-31-97-71z" ] []
        , Svg.path
            [ d "m267 154-52-16 16 24-24 46h78zm-163-16-53 16-17 54h77l-23-46zm71 27 3-58 15-41h-67l15 41 3 58 1 18v45h28v-45z"
            , class "st6"
            ]
            []
        ]
        |> wrap


walletConnect : Element msg
walletConnect =
    svg
        [ viewBox "0 0 300 185"
        , Svg.Attributes.width "40"
        ]
        [ Svg.path [ fill "#3B99FC", Svg.Attributes.fillRule "nonzero", d "M61.4 36.3a127.1 127.1 0 01177.2 0l5.8 5.7a6 6 0 010 8.7l-20 19.7a3.2 3.2 0 01-4.5 0l-8.1-8a88.7 88.7 0 00-123.6 0L79.5 71a3.2 3.2 0 01-4.4 0L55 51.3a6 6 0 010-8.7l6.4-6.3zM280.2 77l18 17.6a6 6 0 010 8.6l-80.9 79.2a6.4 6.4 0 01-8.8 0L151 126.2c-.6-.6-1.6-.6-2.2 0l-57.4 56.2a6.4 6.4 0 01-8.8 0L1.9 103.2a6 6 0 010-8.6L19.8 77a6.4 6.4 0 018.8 0L86 133.2a1.6 1.6 0 002.2 0L145.6 77a6.4 6.4 0 018.8 0l57.4 56.2c.6.6 1.6.6 2.2 0L271.4 77a6.4 6.4 0 018.8 0z" ] [] ]
        |> wrap


sun : Element msg
sun =
    svg
        [ height "24px"
        , viewBox "0 0 24 24"
        , width "24px"
        , fill "#000000"
        ]
        [ Svg.path
            [ d "M0 0h24v24H0z"
            , fill "none"
            ]
            []
        , Svg.path [ d "M20 15.31L23.31 12 20 8.69V4h-4.69L12 .69 8.69 4H4v4.69L.69 12 4 15.31V20h4.69L12 23.31 15.31 20H20v-4.69zM12 18c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z" ] []
        ]
        |> wrap


wrap : Svg msg -> Element msg
wrap =
    Element.html
        >> Element.el []
