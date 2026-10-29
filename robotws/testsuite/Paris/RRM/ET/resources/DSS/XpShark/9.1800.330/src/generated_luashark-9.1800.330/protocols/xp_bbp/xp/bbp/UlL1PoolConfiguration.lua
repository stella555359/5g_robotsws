-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_UlL1PoolConfigurationExtensions = require("xp/bbp/UlL1PoolConfigurationExtensions")


function UlL1PoolConfiguration (fieldName, position)
    return
        fields.Structure({name="UlL1PoolConfiguration", fieldName=fieldName, position=position, size=12}, {
            fields.uint16({name="maxUlPuschPrb", position=0}),
            fields.uint16({name="l1PoolUlPrbEquivalentRequest", position=2}),
            xp_bbp_UlL1PoolConfigurationExtensions("extensions", 4),
        })
end

return UlL1PoolConfiguration
