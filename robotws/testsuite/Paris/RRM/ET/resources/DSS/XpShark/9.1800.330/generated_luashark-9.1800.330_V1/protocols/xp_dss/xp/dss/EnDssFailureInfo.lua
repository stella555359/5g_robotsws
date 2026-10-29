-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_FailureInfoItem = require("xp/dss/FailureInfoItem"),
      xp_dss_EnDssFailureInfoExtensions = require("xp/dss/EnDssFailureInfoExtensions"),
}

function EnDssFailureInfo (fieldName, position)
    return
        fields.Structure({name="EnDssFailureInfo", fieldName=fieldName, position=position, size=16}, {
            fields.DynamicVariableSizedArray({name="failureInfo", position=0, size=8, numSizePaddingBytes=0, numItems=5, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_dss_FailureInfoItem("failureInfo", 0)
            ),
            localVarTable.xp_dss_EnDssFailureInfoExtensions("extensions", 8),
        })
end

return EnDssFailureInfo
