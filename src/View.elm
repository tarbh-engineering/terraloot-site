module View exposing (view)

import Element exposing (Attribute, Color, Element, centerX, column, el, fill, height, padding, paragraph, rgb255, row, spacing, text, width)
import Element.Background as BG
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Eth.Utils
import Helpers.View exposing (cappedWidth, style, when, whenJust)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Img
import Json.Decode as JD
import Maybe.Extra exposing (unwrap)
import Types exposing (Model, Msg)
import View3d


view : Model -> Html Msg
view model =
    (case model.view of
        Types.ViewHome ->
            viewHome model

        Types.ViewAbout ->
            viewAbout model

        Types.ViewClaim ->
            viewClaim model
    )
        |> Element.layoutWith
            { options =
                [ Element.focusStyle
                    { borderColor = Nothing
                    , backgroundColor = Nothing
                    , shadow = Nothing
                    }
                ]
            }
            [ width fill
            , height fill
            , BG.image "/plain.jpg"
            , Font.family [ Font.typeface "Courier New" ]
            ]


viewHome : Model -> Element Msg
viewHome model =
    let
        fn =
            if model.small then
                15

            else
                19
    in
    [ Input.button [ Element.alignRight, hover ]
        { onPress = Just <| Types.SetView Types.ViewAbout
        , label = text "About"
        }
        |> el [ cappedWidth 1000, centerX ]
        |> Helpers.View.when False
    , [ text "TERRA"
      , text "LOOT"
            |> el [ centerX ]
      ]
        |> column
            [ centerX
            , Font.size
                (if model.small then
                    55

                 else
                    70
                )
            , Font.family [ Font.typeface "Mars" ]
            , fadeIn
            ]
    , [ text "Mars has a future. Acquire the tools to take part." ]
        |> paragraph [ Font.center ]
    , Input.button
        [ centerX
        , BG.color white
        , Font.color black
        , padding 15
        , Border.rounded 10
        , hover
        , shadow
        ]
        { onPress = Just <| Types.SetView Types.ViewClaim
        , label = text "Claim NFT"
        }
    , [ Input.button [ Font.underline, hover, Font.size fn ]
            { onPress = Just <| Types.SetView Types.ViewAbout
            , label = text "Learn More"
            }
      , Element.newTabLink [ hover, Font.underline, Font.size fn ]
            { url = "https://twitter.com/terraloot"
            , label = text "Twitter"
            }
      , Element.newTabLink [ hover, Font.underline, Font.size fn ]
            { url = "https://etherscan.io/address/" ++ Eth.Utils.addressToString model.contract
            , label = text "Contract"
            }
      ]
        |> row [ spacing 30, centerX ]
    , Input.button
        [ cappedWidth 400
        , centerX
        , style "cursor" "crosshair"
        ]
        { onPress = Just Types.Create
        , label =
            Img.loot model.index model.loot
                |> Element.html
        }
    ]
        |> column
            [ centerX
            , spacing 40
            , Font.color white
            , padding
                (if model.small then
                    30

                 else
                    60
                )
            , height fill
            , width fill
            ]
        |> scroller
        |> el
            [ height fill
            , width fill
            ]


viewAbout : Model -> Element Msg
viewAbout model =
    [ topBar
    , [ [ [ text "terraform"
                |> el [ Font.size 30 ]
          , text "/ˈterəˌfôrm/"
                |> el [ Element.alignBottom ]
          ]
            |> row [ spacing 10 ]
        , [ text "(especially in science fiction) transform (a planet) so as to resemble the earth, especially so that it can support human life." ]
            |> paragraph [ Font.italic ]
        ]
            |> column
                [ spacing 10
                , Font.size 14
                , BG.color black
                , Font.color white
                , padding 30
                , cappedWidth 450
                , centerX
                ]
      , viewFaq model
      , [ [ Element.newTabLink [ hover, Font.underline ]
                { url = "https://docs.opensea.io/docs/metadata-standards"
                , label = text "Compatible with OpenSea"
                }
          , text "."
          ]
            |> paragraph []
        , jsn
            |> Html.text
            |> Element.html
            |> el
                [ width fill
                , style "white-space" "pre-wrap"
                , style "overflow-wrap" "anywhere"
                , padding 20
                , BG.color white
                , Font.color black
                , Font.size 12
                , width fill
                ]
        , Element.image
            [ cappedWidth 400
            ]
            { src = img
            , description = ""
            }
        ]
            |> column [ spacing 20 ]
            |> wrapper "Attributes"
      , [ [ text "Synthetic gear (for every Ethereum address)" ]
            |> paragraph []
            |> bullet
        , Element.newTabLink [ hover, Font.underline ]
            { url = "https://thegraph.com/explorer"
            , label = text "GRT Subgraph"
            }
            |> bullet
        , text "3D gear viewer"
            |> bullet
        , View3d.view model.turn model.mesh model.box
            |> el [ centerX, BG.color white ]
        ]
            |> column
                [ spacing 20
                , width fill
                ]
            |> wrapper "In Progress"
      , [ Element.newTabLink [ hover, Font.underline ]
            { url = "https://www.lootproject.com"
            , label = text "Loot"
            }
            |> bullet
        , [ Element.newTabLink [ hover, Font.underline ]
                { url = "https://twitter.com/john_c_palmer/status/1432606797186179072"
                , label = text "\"Really think we’re in a different era now.\""
                }
          ]
            |> paragraph []
            |> bullet
        ]
            |> column [ spacing 20 ]
            |> wrapper "Inspiration"
      ]
        |> column
            [ spacing 40
            , cappedWidth 750
            , centerX
            , height fill

            --, Element.paddingXY 10 10
            , padding 10
            ]
        |> scroller
    ]
        |> column
            [ height fill
            , width fill
            ]


viewClaim : Model -> Element Msg
viewClaim model =
    [ topBar
    , model.address
        |> unwrap
            ([ connectButton
                |> el [ centerX ]
                |> when model.hasWallet
             , wButton
             ]
                |> column [ centerX, spacing 20 ]
            )
            (\addr ->
                [ [ text "Connected"
                        |> el [ Font.bold ]
                  , Eth.Utils.addressToString addr
                        |> (\ad ->
                                String.left 8 ad
                                    ++ "..."
                                    ++ String.right 8 ad
                           )
                        |> text
                  , Input.button
                        [ hover
                        , Font.underline
                        , Element.alignRight
                        , Font.size 15
                        ]
                        { onPress = Just Types.ClearWallet
                        , label = text "Disconnect"
                        }
                  ]
                    |> column
                        [ spacing 15
                        , Font.color black
                        , Font.size 17
                        , BG.color white
                        , padding 15
                        , Border.rounded 10
                        , centerX
                        ]
                , Input.text
                    [ onEnter Types.Claim

                    --, spinner
                    --|> el [ Element.alignRight, Element.centerY, Element.paddingXY 5 0 ]
                    --|> when model.inProgress
                    --|> Element.inFront
                    --, cappedWidth 250
                    , Font.color black
                    , centerX
                    , Html.Attributes.maxlength 10
                        |> Element.htmlAttribute

                    --, Html.Attributes.disabled model.inProgress
                    --|> Element.htmlAttribute
                    ]
                    { onChange = Types.IdUpdate
                    , placeholder =
                        text "0-9999"
                            |> Input.placeholder []
                            |> Just
                    , text = model.claim
                    , label = Input.labelHidden ""
                    }
                , model.claimTx
                    |> whenJust
                        (\tx ->
                            [ text "Success!"
                                |> el [ Font.bold, centerX ]
                            , Element.newTabLink [ Font.underline, hover ]
                                { url = "https://etherscan.io/tx/" ++ Eth.Utils.txHashToString tx
                                , label = text "View transaction"
                                }
                            ]
                                |> column
                                    [ padding 10
                                    , centerX
                                    , BG.color white
                                    , spacing 10
                                    ]
                        )
                ]
                    |> column [ spacing 20, centerX ]
            )
    ]
        |> column
            [ spacing 30
            , width fill
            , padding 30
            ]


viewFaq : Model -> Element Msg
viewFaq model =
    [ [ subheader "What is Terraloot?"
      , [ text "Terraloot is a collection of 10,000 randomly generated gearsets, stored completely on-chain as ERC721 NFTs." ]
            |> paragraph [ read ]
      ]
        |> column [ spacing 10 ]
    , [ subheader "How are the NFTs distributed?"
      , [ text "The first 9,750 bags can be claimed by anyone, for gas cost only. The final 250 bags can be claimed by the contract owner." ]
            |> paragraph [ read ]
      ]
        |> column [ spacing 10 ]
    , [ subheader "Where can I get one?"
      , [ text "You can currently claim Terraloot "
        , Input.button [ Font.underline, hover ]
            { onPress = Just <| Types.SetView Types.ViewClaim
            , label = text "here"
            }
        , text " or by interacting with the smart contract "
        , Element.newTabLink [ Font.underline, hover ]
            { url = "https://etherscan.io/address/" ++ Eth.Utils.addressToString model.contract ++ "#writeContract"
            , label = text "on Etherscan"
            }
        , text "."
        ]
            |> paragraph [ read ]
      ]
        |> column [ spacing 10 ]
    , [ subheader "How is the gear generated?"
      , [ text "All gear contents are temporary until the public distribution ends, at which point a random seed will be chosen, and used to generate the final bags." ]
            |> paragraph [ read ]
      ]
        |> column [ spacing 10 ]
    , [ subheader "What token ids can be minted?"
      , [ text "Any id from 0-9999 can be minted, on a first come, first served basis. The 250 owner tokens will be whatever is left after the initial public distribution." ]
            |> paragraph [ read ]
      ]
        |> column [ spacing 10 ]
    , [ subheader "Who built this?"
      , Element.newTabLink [ hover, read ]
            { url = "https://github.com/ronanyeah"
            , label = text "@ronanyeah"
            }
      ]
        |> column [ spacing 10 ]
    ]
        |> column
            [ spacing 30
            , width fill
            ]
        |> wrapper "FAQ"


bullet : Element msg -> Element msg
bullet elem =
    [ text "-"
        |> el [ Element.alignTop ]
    , elem
    ]
        |> row
            [ spacing 10
            , width fill
            ]


wrapper : String -> Element msg -> Element msg
wrapper str elem =
    [ header str
    , elem
    ]
        |> column
            [ spacing 30
            , width fill
            , BG.color black
            , Font.color white
            , padding 30
            ]


header : String -> Element msg
header =
    text >> el [ Font.bold, Font.size 30 ]


subheader : String -> Element msg
subheader =
    text >> List.singleton >> paragraph [ Font.bold ]


white : Color
white =
    rgb255 255 255 255


black : Color
black =
    rgb255 0 0 32


fadeIn : Attribute msg
fadeIn =
    style "animation" "fadeIn 1s"


hover : Attribute msg
hover =
    Element.mouseOver [ fade ]


read : Attribute msg
read =
    Font.family [ Font.typeface "Roboto" ]


fade : Element.Attr a b
fade =
    Element.alpha 0.7


jsn : String
jsn =
    """[
  {
    "trait_type": "Outfit",
    "value": "Opticamo"
  },
  {
    "trait_type": "Tool",
    "value": "Vibrahammer"
  },
  {
    "trait_type": "Handheld Gadget",
    "value": "Flare Launcher"
  },
  {
    "trait_type": "Wearable Gadget",
    "value": "Utility Belt"
  },
  {
    "trait_type": "Shoulder Gadget",
    "value": "“Acid Galvanized” Imaging Sonar 🛸"
  },
  {
    "trait_type": "Backpack",
    "value": "“Entropy Activated” Big Box 🦾"
  },
  {
    "trait_type": "External Gadget",
    "value": "Scootbike"
  },
  {
    "trait_type": "Rig",
    "value": "Area Shield"
  }
]"""


img : String
img =
    "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaW5ZTWluIG1lZXQiIHZpZXdCb3g9IjAgMCAzNTAgMzUwIj48ZGVmcz48Y2xpcFBhdGggaWQ9ImNscCI+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIvPjwvY2xpcFBhdGg+PC9kZWZzPjxzdHlsZT50ZXh0e2ZpbGw6I2ZmZjtmb250LWZhbWlseTpTb3VyY2UgQ29kZSBQcm87Zm9udC1zaXplOjEzcHh9LnRhZ3tmb250LXNpemU6MjRweH1lbGxpcHNle2NsaXAtcGF0aDp1cmwoI2NscCl9PC9zdHlsZT48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjMDAwMDIwIi8+PGVsbGlwc2UgY3g9IjMyMCIgY3k9IjMyMCIgcng9IjEzMCIgcnk9IjEzMCIgZmlsbD0iI2MzMjIwNSIvPjx0ZXh0IHg9IjI0MCIgeT0iMzM1IiBjbGFzcz0idGFnIj5UTDoyODI5PC90ZXh0Pjx0ZXh0IHg9IjgiIHk9IjIwIj5PcHRpY2FtbzwvdGV4dD48dGV4dCB4PSI4IiB5PSI0MyI+VmlicmFoYW1tZXI8L3RleHQ+PHRleHQgeD0iOCIgeT0iNjYiPkZsYXJlIExhdW5jaGVyPC90ZXh0Pjx0ZXh0IHg9IjgiIHk9Ijg5Ij5VdGlsaXR5IEJlbHQ8L3RleHQ+PHRleHQgeD0iOCIgeT0iMTEyIj7igJxBY2lkIEdhbHZhbml6ZWTigJ0gSW1hZ2luZyBTb25hciDwn5u4PC90ZXh0Pjx0ZXh0IHg9IjgiIHk9IjEzNSI+4oCcRW50cm9weSBBY3RpdmF0ZWTigJ0gQmlnIEJveCDwn6a+PC90ZXh0Pjx0ZXh0IHg9IjgiIHk9IjE1OCI+U2Nvb3RiaWtlPC90ZXh0Pjx0ZXh0IHg9IjgiIHk9IjE4MSI+QXJlYSBTaGllbGQ8L3RleHQ+PC9zdmc+"


scroller : Element msg -> Element msg
scroller =
    el
        [ height fill
        , width fill
        , style "min-height" "auto"
        , style "scrollbar-width" "none"
        , Element.scrollbarY
        , Html.Attributes.class "scroll"
            |> Element.htmlAttribute
        ]


connectButton : Element Msg
connectButton =
    Input.button [ BG.color white, shadow, padding 15, Border.rounded 10, hover ]
        { onPress = Just Types.Connect
        , label =
            [ Img.metamask, text "MetaMask" ]
                |> row [ spacing 20, Font.color black, Font.size 17 ]
        }


wButton : Element Msg
wButton =
    Input.button [ BG.color white, shadow, padding 15, Border.rounded 10, hover ]
        { onPress = Just Types.WConnect
        , label =
            [ Img.walletConnect, text "WalletConnect" ]
                |> row [ spacing 20, Font.color black, Font.size 17 ]
        }


onEnter : msg -> Attribute msg
onEnter msg =
    JD.field "key" JD.string
        |> JD.andThen
            (\key ->
                if key == "Enter" then
                    JD.succeed msg

                else
                    JD.fail ""
            )
        |> Html.Events.on "keydown"
        |> Element.htmlAttribute


shadow : Attribute msg
shadow =
    Border.shadow
        { offset = ( 3, 3 )
        , size = 0
        , blur = 3
        , color = black
        }


topBar : Element Msg
topBar =
    Input.button
        [ centerX
        , Font.size 25
        , Font.family [ Font.typeface "Mars" ]
        , hover
        , fadeIn
        , Element.alignLeft
        , padding 30
        , Font.color white
        ]
        { onPress = Just <| Types.SetView Types.ViewHome
        , label = text "TERRALOOT"
        }
        |> el [ cappedWidth 1000, centerX ]