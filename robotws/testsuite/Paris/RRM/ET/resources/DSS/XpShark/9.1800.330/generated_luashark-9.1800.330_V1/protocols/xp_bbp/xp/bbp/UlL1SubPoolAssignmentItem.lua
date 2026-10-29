-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_UlL1SubPoolAssignmentItemExtensions = require("xp/bbp/UlL1SubPoolAssignmentItemExtensions"),
}

function UlL1SubPoolAssignmentItem (fieldName, position)
    return
        fields.Structure({name="UlL1SubPoolAssignmentItem", fieldName=fieldName, position=position, size=16}, {
            fields.uint32({name="l1SubPoolId", position=0}),
            fields.uint16({name="maxUlPuschPrb", position=4}),
            fields.Padding({name="maxUlPuschPrb_extensions_padding", position=6, size=2}),
            localVarTable.xp_bbp_UlL1SubPoolAssignmentItemExtensions("extensions", 8),
        })
end

return UlL1SubPoolAssignmentItem
