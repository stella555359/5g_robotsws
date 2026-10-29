-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_L1SubPoolPdschLayerConfigurationExtensions = require("xp/bbp/L1SubPoolPdschLayerConfigurationExtensions")


function L1SubPoolPdschLayerConfiguration (fieldName, position)
    return
        fields.Structure({name="L1SubPoolPdschLayerConfiguration", fieldName=fieldName, position=position, size=24}, {
            fields.uint32({name="l1SubPoolId", position=0}),
            fields.uint16({name="l1SubPoolCells", position=4}),
            fields.uint16({name="l1SubPoolPdschLayersRequest", position=6}),
            fields.uint16({name="minL1SubPoolPdschLayers", position=8}),
            fields.Padding({name="minL1SubPoolPdschLayers_dlL1SubPoolLoad_padding", position=10, size=2}),
            fields.uint32({name="dlL1SubPoolLoad", position=12}),
            xp_bbp_L1SubPoolPdschLayerConfigurationExtensions("extensions", 16),
        })
end

return L1SubPoolPdschLayerConfiguration
