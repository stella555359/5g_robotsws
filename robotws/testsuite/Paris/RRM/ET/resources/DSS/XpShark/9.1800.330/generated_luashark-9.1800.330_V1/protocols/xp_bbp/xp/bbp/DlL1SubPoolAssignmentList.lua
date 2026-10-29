-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_DlL1SubPoolAssignmentItem = require("xp/bbp/DlL1SubPoolAssignmentItem"),
      xp_bbp_DlL1SubPoolAssignmentListExtensions = require("xp/bbp/DlL1SubPoolAssignmentListExtensions"),
}

function DlL1SubPoolAssignmentList (fieldName, position)
    return
        fields.Structure({name="DlL1SubPoolAssignmentList", fieldName=fieldName, position=position, size=16}, {
            fields.DynamicVariableSizedArray({name="items", position=0, size=8, numSizePaddingBytes=0, numItems=8, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_bbp_DlL1SubPoolAssignmentItem("items", 0)
            ),
            localVarTable.xp_bbp_DlL1SubPoolAssignmentListExtensions("extensions", 8),
        })
end

return DlL1SubPoolAssignmentList
