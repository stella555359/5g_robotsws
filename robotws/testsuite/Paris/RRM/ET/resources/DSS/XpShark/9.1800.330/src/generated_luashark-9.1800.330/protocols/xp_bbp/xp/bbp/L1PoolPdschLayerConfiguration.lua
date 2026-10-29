-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_L1PoolPdschLayerConfigurationExtensions = require("xp/bbp/L1PoolPdschLayerConfigurationExtensions")


function L1PoolPdschLayerConfiguration (fieldName, position)
    return
        fields.Structure({name="L1PoolPdschLayerConfiguration", fieldName=fieldName, position=position, size=12}, {
            fields.uint16({name="maxPdschLayers", position=0}),
            fields.uint16({name="l1PoolPdschLayersRequest", position=2}),
            xp_bbp_L1PoolPdschLayerConfigurationExtensions("extensions", 4),
        })
end

return L1PoolPdschLayerConfiguration
