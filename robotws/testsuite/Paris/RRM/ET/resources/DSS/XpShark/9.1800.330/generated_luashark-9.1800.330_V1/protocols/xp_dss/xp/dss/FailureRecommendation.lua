-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_RecommendedActions = require("xp/dss/RecommendedActions"),
}

function FailureRecommendation (fieldName, position)
    return
        fields.Structure({name="FailureRecommendation", fieldName=fieldName, position=position, size=244}, {
            fields.StaticVariableSizedArray({name="actions", position=0, size=244, numSizePaddingBytes=0, numItems=5, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_RecommendedActions("actions", 0)
            ),
        })
end

return FailureRecommendation
