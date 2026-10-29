-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_ParameterTypeNumber = require("xp/dss/ParameterTypeNumber"),
      xp_dss_ParameterTypeBitstring = require("xp/dss/ParameterTypeBitstring"),
      xp_dss_ParameterTypeString = require("xp/dss/ParameterTypeString"),
      xp_dss_ParameterTypePrbAreas = require("xp/dss/ParameterTypePrbAreas"),
}

function FailureParameterInfo (fieldName, position)
    return
        fields.DynamicUnion({name="FailureParameterInfo", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            localVarTable.xp_dss_ParameterTypeNumber("number", 0),
            localVarTable.xp_dss_ParameterTypeBitstring("bitstring", 0),
            localVarTable.xp_dss_ParameterTypeString("string", 0),
            localVarTable.xp_dss_ParameterTypePrbAreas("prbArea", 0),
            },
            {0, 2, 3, 4, 5}
        )
end

return FailureParameterInfo
