-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_Time = require("xp/dss/Time"),
      xp_dss_PrbRange = require("xp/dss/PrbRange"),
}

function PrbAreaCoordinationItem (fieldName, position)
    return
        fields.Structure({name="PrbAreaCoordinationItem", fieldName=fieldName, position=position, size=28}, {
            localVarTable.xp_dss_Time("patternStartTime", 0),
            fields.uint16({name="periodicity", position=16}),
            fields.Padding({name="periodicity_prbRangeList_padding", position=18, size=2}),
            fields.DynamicVariableSizedArray({name="prbRangeList", position=20, size=8, numSizePaddingBytes=0, numItems=2, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_dss_PrbRange("prbRangeList", 20)
            ),
        })
end

return PrbAreaCoordinationItem
