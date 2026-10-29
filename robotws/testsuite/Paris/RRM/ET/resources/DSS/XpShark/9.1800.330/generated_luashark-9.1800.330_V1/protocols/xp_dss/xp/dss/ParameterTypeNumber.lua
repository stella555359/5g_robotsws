-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_FailureDescription = require("xp/dss/FailureDescription"),
      xp_dss_NumberParameterValues = require("xp/dss/NumberParameterValues"),
      xp_dss_ParameterTypeNumberExtensions = require("xp/dss/ParameterTypeNumberExtensions"),
}

function ParameterTypeNumber (fieldName, position)
    return
        fields.Structure({name="ParameterTypeNumber", fieldName=fieldName, position=position, size=284}, {
            localVarTable.xp_dss_FailureDescription("parameterName", 0),
            fields.uint32({name="parameterValueLength", position=256}),
            fields.DynamicVariableSizedArray({name="parameterValues", position=260, size=8, numSizePaddingBytes=0, numItems=6, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_dss_NumberParameterValues("parameterValues", 260)
            ),
            fields.DynamicVariableSizedArray({name="conflictingValues", position=268, size=8, numSizePaddingBytes=0, numItems=20, numPaddingBytes=0},
                fields.uint32, fields.uint32, fields.int32({name="item", position=268})
            ),
            localVarTable.xp_dss_ParameterTypeNumberExtensions("extensions", 276),
        })
end

return ParameterTypeNumber
