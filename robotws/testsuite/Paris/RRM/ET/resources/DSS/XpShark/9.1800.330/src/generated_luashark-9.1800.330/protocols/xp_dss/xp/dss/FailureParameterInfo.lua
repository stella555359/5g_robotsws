-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_ParameterTypeNumber = require("xp/dss/ParameterTypeNumber")
local xp_dss_ParameterTypeBitstring = require("xp/dss/ParameterTypeBitstring")
local xp_dss_ParameterTypeString = require("xp/dss/ParameterTypeString")
local xp_dss_ParameterTypePrbAreas = require("xp/dss/ParameterTypePrbAreas")


function FailureParameterInfo (fieldName, position)
    return
        fields.DynamicUnion({name="FailureParameterInfo", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_dss_ParameterTypeNumber("number", 0),
            xp_dss_ParameterTypeBitstring("bitstring", 0),
            xp_dss_ParameterTypeString("string", 0),
            xp_dss_ParameterTypePrbAreas("prbArea", 0),
            },
            {0, 2, 3, 4, 5}
        )
end

return FailureParameterInfo
