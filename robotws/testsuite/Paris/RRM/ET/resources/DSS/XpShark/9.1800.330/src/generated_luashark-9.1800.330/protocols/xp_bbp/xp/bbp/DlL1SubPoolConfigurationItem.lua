-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_DlL1SubPoolConfigurationItemExtensions = require("xp/bbp/DlL1SubPoolConfigurationItemExtensions")


function DlL1SubPoolConfigurationItem (fieldName, position)
    return
        fields.Structure({name="DlL1SubPoolConfigurationItem", fieldName=fieldName, position=position, size=20}, {
            fields.uint32({name="l1SubPoolId", position=0}),
            fields.uint16({name="l1SubPoolDlPrbEquivalentRequest", position=4}),
            fields.uint16({name="minL1SubPoolDlPrbEquivalent", position=6}),
            fields.uint32({name="dlL1SubPoolLoad", position=8}),
            xp_bbp_DlL1SubPoolConfigurationItemExtensions("extensions", 12),
        })
end

return DlL1SubPoolConfigurationItem
