-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_FailureDescription = require("xp/dss/FailureDescription"),
      xp_dss_BitstringParamValue = require("xp/dss/BitstringParamValue"),
      xp_dss_ParameterTypeBitstringExtensions = require("xp/dss/ParameterTypeBitstringExtensions"),
}

function ParameterTypeBitstring (fieldName, position)
    return
        fields.Structure({name="ParameterTypeBitstring", fieldName=fieldName, position=position, size=340}, {
            localVarTable.xp_dss_FailureDescription("parameterName", 0),
            fields.uint32({name="parameterValueLength", position=256}),
            localVarTable.xp_dss_BitstringParamValue("parameterValueLte", 260),
            localVarTable.xp_dss_BitstringParamValue("parameterValueNr", 292),
            fields.DynamicVariableSizedArray({name="conflictingBitPositions", position=324, size=8, numSizePaddingBytes=0, numItems=255, numPaddingBytes=0},
                fields.uint32, fields.uint32, fields.uint32({name="item", position=324})
            ),
            localVarTable.xp_dss_ParameterTypeBitstringExtensions("extensions", 332),
        })
end

return ParameterTypeBitstring
