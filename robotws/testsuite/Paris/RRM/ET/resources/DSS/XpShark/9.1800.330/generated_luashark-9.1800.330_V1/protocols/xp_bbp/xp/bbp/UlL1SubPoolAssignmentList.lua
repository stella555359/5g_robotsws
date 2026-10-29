-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_UlL1SubPoolAssignmentItem = require("xp/bbp/UlL1SubPoolAssignmentItem"),
      xp_bbp_UlL1SubPoolAssignmentListExtensions = require("xp/bbp/UlL1SubPoolAssignmentListExtensions"),
}

function UlL1SubPoolAssignmentList (fieldName, position)
    return
        fields.Structure({name="UlL1SubPoolAssignmentList", fieldName=fieldName, position=position, size=16}, {
            fields.DynamicVariableSizedArray({name="items", position=0, size=8, numSizePaddingBytes=0, numItems=8, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_bbp_UlL1SubPoolAssignmentItem("items", 0)
            ),
            localVarTable.xp_bbp_UlL1SubPoolAssignmentListExtensions("extensions", 8),
        })
end

return UlL1SubPoolAssignmentList
