-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_RecommendedActions = require("xp/dss/RecommendedActions")


function FailureRecommendation (fieldName, position)
    return
        fields.Structure({name="FailureRecommendation", fieldName=fieldName, position=position, size=244}, {
            fields.StaticVariableSizedArray({name="actions", position=0, size=244, numSizePaddingBytes=0, numItems=5, numPaddingBytes=0},
                fields.uint32, xp_dss_RecommendedActions("actions", 0)
            ),
        })
end

return FailureRecommendation
