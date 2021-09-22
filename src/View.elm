module View exposing (view)

import Array exposing (Array)
import Element exposing (Attribute, Color, Element, centerX, column, el, fill, height, padding, paragraph, rgb255, row, spacing, text, width)
import Element.Background as BG
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Eth.Utils
import Helpers.View exposing (cappedWidth, style, when, whenAttr, whenJust)
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
            , BG.image Img.bg
            , Font.family [ Font.typeface "Courier New" ]
            ]


viewHome : Model -> Element Msg
viewHome model =
    let
        fn =
            if model.small then
                15

            else
                20
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
            , Font.color white
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
        |> paragraph
            [ Font.center
            , Font.color white
            ]
    , btn
        (Just <| Types.SetView Types.ViewClaim)
        (text "Claim NFT")
        |> el [ centerX ]
    , [ Input.button [ Font.underline, hover, Font.size fn ]
            { onPress = Just <| Types.SetView Types.ViewAbout
            , label = text "FAQ"
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
        |> row [ spacing 30, centerX, Font.color white ]
    , display model.index model.loot
        |> el [ centerX, cappedWidth 400 ]
    ]
        |> column
            [ centerX
            , spacing 40
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
            |> Element.wrappedRow [ spacing 10 ]
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
        , [ "Outfit"
          , "Tool"
          , "Handheld Gadget"
          , "Wearable Gadget"
          , "Shoulder Gadget"
          , "Backpack"
          , "External Gadget"
          , "Rig"
          ]
            |> List.map
                (\txt ->
                    text <| "- " ++ txt
                )
            |> column [ spacing 10 ]
        , Img.jsn model.loot
            |> Html.text
            |> Element.html
            |> el
                [ style "white-space" "pre-wrap"
                , style "overflow-wrap" "anywhere"
                , padding 20
                , BG.color white
                , Font.color black
                , Font.size 12
                ]
        , display model.index model.loot
            |> el [ cappedWidth 400 ]
        ]
            |> column [ spacing 30 ]
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
      , [ text "This website is "
        , Element.newTabLink [ hover, Font.underline ]
            { url = "https://github.com/tarbh-engineering/terraloot-site"
            , label = text "open-source"
            }
        , text "."
        ]
            |> paragraph
                [ width fill
                , BG.color black
                , Font.color white
                , padding 30
                , Font.center
                ]
      ]
        |> column
            [ spacing 40
            , cappedWidth 750
            , centerX
            , height fill
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
                (if model.connectInProg then
                    Nothing

                 else
                    Just Types.Connect
                )
                |> el [ centerX ]
                |> when model.hasWallet
             , wButton
                (if model.connectInProg then
                    Nothing

                 else
                    Just Types.WConnect
                )
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
                        , Font.size 17
                        , BG.color white
                        , padding 15
                        , Border.rounded 10
                        , centerX
                        ]
                , [ Input.text
                        [ onEnter Types.Claim
                            |> whenAttr (not model.claimInProg)
                        , spinner
                            |> el
                                [ Element.alignRight
                                , Element.centerY
                                , Element.paddingXY 10 0
                                ]
                            |> when model.claimInProg
                            |> Element.inFront
                        , Border.rounded 0
                        , Font.color black
                        , Html.Attributes.maxlength 4
                            |> Element.htmlAttribute
                        , Html.Attributes.disabled model.claimInProg
                            |> Element.htmlAttribute
                        ]
                        { onChange = Types.IdUpdate
                        , placeholder =
                            text "0-9999"
                                |> Input.placeholder []
                                |> Just
                        , text = model.claim
                        , label = Input.labelHidden ""
                        }
                  , btn
                        (if model.claimInProg then
                            Nothing

                         else
                            Just Types.Claim
                        )
                        (text "Submit")
                        |> el [ Element.alignRight ]
                  , model.claimTx
                        |> whenJust
                            (\tx ->
                                [ text "Success!"
                                    |> el [ Font.bold, centerX, Font.size 21 ]
                                , Element.newTabLink [ Font.underline, hover, Font.size 17 ]
                                    { url = "https://etherscan.io/tx/" ++ Eth.Utils.txHashToString tx
                                    , label = text "View transaction"
                                    }
                                ]
                                    |> column
                                        [ padding 10
                                        , centerX
                                        , spacing 10
                                        ]
                            )
                  ]
                    |> column [ spacing 20 ]
                    |> wrapper "Claim a token"
                    |> el [ centerX ]
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
      , Element.newTabLink [ hover, read, Font.underline ]
            { url = "https://github.com/ronanyeah"
            , label = text "ronanmccabe.eth"
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


connectButton : Maybe msg -> Element msg
connectButton msg =
    [ Img.metamask, text "MetaMask" ]
        |> row [ spacing 20, Font.size 17 ]
        |> btn msg


wButton : Maybe msg -> Element msg
wButton msg =
    [ Img.walletConnect, text "WalletConnect" ]
        |> row [ spacing 20, Font.size 17 ]
        |> btn msg


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


btn : Maybe msg -> Element msg -> Element msg
btn msg elem =
    Input.button
        [ BG.color white
        , Font.color black
        , shadow
        , padding 15
        , Border.rounded 10
        , hover
            |> whenAttr (msg /= Nothing)
        , style "cursor" "wait"
            |> whenAttr (msg == Nothing)
        ]
        { onPress = msg
        , label = elem
        }


rotate : Attribute msg
rotate =
    style "animation" "rotation 0.7s infinite linear"


spinner : Element msg
spinner =
    Img.sun
        |> el
            [ rotate
            ]


display : Int -> Array String -> Element Msg
display n xs =
    Input.button
        [ width fill
        , style "cursor" "crosshair"
        , Element.mouseOver [ Border.glow white 0.6 ]
        ]
        { onPress = Just Types.Create
        , label =
            Img.loot n xs
                |> Element.html
        }
