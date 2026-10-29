-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
