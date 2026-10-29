-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_ActionItem = require("xp/dss/ActionItem"),
}

function RecommendedActions (fieldName, position)
    return
        fields.Structure({name="RecommendedActions", fieldName=fieldName, position=position, size=48}, {
            fields.uint32({name="actionName", position=0}),
            fields.StaticVariableSizedArray({name="actionItem", position=4, size=44, numSizePaddingBytes=0, numItems=5, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_ActionItem("actionItem", 4)
            ),
        })
end

return RecommendedActions
