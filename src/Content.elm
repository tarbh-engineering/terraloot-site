module Content exposing (applyMagic, backpacks, bonuses, externalGadgets, gen, handheldGadgets, outfits, prefixes, rigs, shoulderGadgets, suffixes, tools, wearableGadgets)

import Array exposing (Array)
import Random exposing (Generator)


gen : Generator (List ( Int, Int ))
gen =
    Random.list 8
        (Random.pair (Random.int 0 25000) (Random.int 0 21))


pluck : Int -> Array String -> String
pluck n xs =
    Random.step (Random.int 0 (Array.length xs - 1)) (Random.initialSeed n)
        |> Tuple.first
        |> (\v ->
                Array.get v xs
           )
        |> Maybe.withDefault "OOPS"


applyMagic : Int -> Int -> Array String -> String
applyMagic n g xs =
    pluck n xs
        |> (\str ->
                if g >= 20 then
                    [ "“" ++ pluck n bonuses
                    , pluck n prefixes ++ "”"
                    , str
                    , pluck n suffixes
                    ]

                else if g >= 18 then
                    [ "“" ++ pluck n bonuses
                    , pluck n prefixes ++ "”"
                    , str
                    ]

                else if g >= 15 then
                    [ "“" ++ pluck n prefixes ++ "”"
                    , str
                    ]

                else
                    [ str ]
           )
        |> String.join " "


outfits : Array String
outfits =
    [ "Recon Suit"
    , "Tool Harness"
    , "Opticamo"
    , "Envirosuit"
    , "Wingsuit"
    , "Nanosuit"
    , "Z Series"
    , "Tough Gear"
    , "Thermafoil"
    , "Jumpsuit"
    , "Exosuit"
    , "Rockbuster"
    ]
        |> Array.fromList


tools : Array String
tools =
    [ "Optical Drill"
    , "Ore Laser"
    , "Arc Welder"
    , "Vibrahammer"
    , "Nano Saw"
    , "Plasma Cutter"
    , "Thermal Lance"
    , "Shatter Beam"
    , "Pulsecaster"
    , "Shovel"
    ]
        |> Array.fromList


handheldGadgets : Array String
handheldGadgets =
    [ "Shaped Charge"
    , "Multitool"
    , "Geomorpher"
    , "Ascender"
    , "Flare Launcher"
    , "Sampling Probe"
    , "Holo Scanner"
    , "Zero Point Shifter"
    ]
        |> Array.fromList


externalGadgets : Array String
externalGadgets =
    [ "UAV"
    , "UGV"
    , "Speedwheel"
    , "Scootbike"
    , "Lab Kit"
    , "Ground Radar"
    , "Duneboard"
    , "Glider"
    ]
        |> Array.fromList


wearableGadgets : Array String
wearableGadgets =
    [ "Spectrograph"
    , "Utility Belt"
    , "Transponder"
    , "Magtool"
    , "Grip Gloves"
    , "Landing Absorbers"
    , "Line Launcher"
    , "Rappel Belt"
    ]
        |> Array.fromList


shoulderGadgets : Array String
shoulderGadgets =
    [ "SuperCam"
    , "Soundbar"
    , "LIDAR System"
    , "Imaging Sonar"
    , "Holo Projector"
    , "Beam Designator"
    , "Hook Launcher"
    , "Floodlight"
    ]
        |> Array.fromList


backpacks : Array String
backpacks =
    [ "Faraday Shield"
    , "Satlink"
    , "Charge Pack"
    , "Booster"
    , "Big Box"
    , "Parachute"
    , "Solar Array"
    , "Power Arm"
    ]
        |> Array.fromList


rigs : Array String
rigs =
    [ "Polymer Web"
    , "Turbofan"
    , "Ore Breaker"
    , "Area Shield"
    , "Meshnet Node"
    , "Ground Station"
    , "Power Core"
    , "Tesla Coil"
    , "Balloon"
    , "Replicator"
    , "Drill Stack"
    , "Modular Reactor"
    ]
        |> Array.fromList


suffixes : Array String
suffixes =
    [ "⚡️"
    , "🎲"
    , "🛸"
    , "🌎"
    , "🪐"
    , "🧊"
    , "🔋"
    , "💎"
    , "✨"
    , "🧲"
    , "🦾"
    , "📡"
    , "🛡"
    , "🛠"
    , "⏱"
    , "🛰"
    ]
        |> Array.fromList


bonuses : Array String
bonuses =
    [ "Titanium"
    , "Platinum"
    , "Graphene"
    , "Diamond"
    , "Fission"
    , "Entropy"
    , "Alkali"
    , "Plasma"
    , "Fusion"
    , "Prime"
    , "Alpha"
    , "Earth"
    , "Polar"
    , "Beta"
    , "Acid"
    , "Mass"
    , "Ion"
    ]
        |> Array.fromList


prefixes : Array String
prefixes =
    [ "Magnetized"
    , "Galvanized"
    , "Calibrated"
    , "Serialized"
    , "Converted"
    , "Magnified"
    , "Certified"
    , "Activated"
    , "Energized"
    , "Regulated"
    , "Refitted"
    , "Enhanced"
    , "Oxidized"
    , "Adjusted"
    , "Upgraded"
    , "Modified"
    , "Charged"
    , "Plated"
    , "Tuned"
    ]
        |> Array.fromList
