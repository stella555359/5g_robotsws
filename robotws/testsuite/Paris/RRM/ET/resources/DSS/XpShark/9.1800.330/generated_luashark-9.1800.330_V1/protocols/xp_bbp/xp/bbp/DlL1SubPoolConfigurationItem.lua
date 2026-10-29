-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_DlL1SubPoolConfigurationItemExtensions = require("xp/bbp/DlL1SubPoolConfigurationItemExtensions"),
}

function DlL1SubPoolConfigurationItem (fieldName, position)
    return
        fields.Structure({name="DlL1SubPoolConfigurationItem", fieldName=fieldName, position=position, size=20}, {
            fields.uint32({name="l1SubPoolId", position=0}),
            fields.uint16({name="l1SubPoolDlPrbEquivalentRequest", position=4}),
            fields.uint16({name="minL1SubPoolDlPrbEquivalent", position=6}),
            fields.uint32({name="dlL1SubPoolLoad", position=8}),
            localVarTable.xp_bbp_DlL1SubPoolConfigurationItemExtensions("extensions", 12),
        })
end

return DlL1SubPoolConfigurationItem
