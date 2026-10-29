-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_UlL1SubPoolConfigurationItemExtensions = require("xp/bbp/UlL1SubPoolConfigurationItemExtensions")


function UlL1SubPoolConfigurationItem (fieldName, position)
    return
        fields.Structure({name="UlL1SubPoolConfigurationItem", fieldName=fieldName, position=position, size=20}, {
            fields.uint32({name="l1SubPoolId", position=0}),
            fields.uint16({name="l1SubPoolUlPrbEquivalentRequest", position=4}),
            fields.uint16({name="minL1SubPoolUlPrbEquivalent", position=6}),
            fields.uint32({name="ulL1SubPoolLoad", position=8}),
            xp_bbp_UlL1SubPoolConfigurationItemExtensions("extensions", 12),
        })
end

return UlL1SubPoolConfigurationItem
