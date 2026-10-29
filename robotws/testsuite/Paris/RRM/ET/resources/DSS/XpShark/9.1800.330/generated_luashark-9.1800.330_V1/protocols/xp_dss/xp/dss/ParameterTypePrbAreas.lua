-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_FailureDescription = require("xp/dss/FailureDescription"),
      xp_dss_PrbAreas = require("xp/dss/PrbAreas"),
      xp_dss_ParameterTypePrbAreasExtensions = require("xp/dss/ParameterTypePrbAreasExtensions"),
}

function ParameterTypePrbAreas (fieldName, position)
    return
        fields.Structure({name="ParameterTypePrbAreas", fieldName=fieldName, position=position, size=376}, {
            localVarTable.xp_dss_FailureDescription("parameterName", 0),
            fields.StaticVariableSizedArray({name="parameterValueLte", position=256, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_PrbAreas("parameterValueLte", 256)
            ),
            fields.StaticVariableSizedArray({name="parameterValueNr", position=312, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_PrbAreas("parameterValueNr", 312)
            ),
            localVarTable.xp_dss_ParameterTypePrbAreasExtensions("extensions", 368),
        })
end

return ParameterTypePrbAreas
