-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_FailureDescription = require("xp/dss/FailureDescription")
local xp_dss_BitstringParamValue = require("xp/dss/BitstringParamValue")
local xp_dss_ParameterTypeBitstringExtensions = require("xp/dss/ParameterTypeBitstringExtensions")


function ParameterTypeBitstring (fieldName, position)
    return
        fields.Structure({name="ParameterTypeBitstring", fieldName=fieldName, position=position, size=340}, {
            xp_dss_FailureDescription("parameterName", 0),
            fields.uint32({name="parameterValueLength", position=256}),
            xp_dss_BitstringParamValue("parameterValueLte", 260),
            xp_dss_BitstringParamValue("parameterValueNr", 292),
            fields.DynamicVariableSizedArray({name="conflictingBitPositions", position=324, size=8, numSizePaddingBytes=0, numItems=255, numPaddingBytes=0},
                fields.uint32, fields.uint32, fields.uint32({name="item", position=324})
            ),
            xp_dss_ParameterTypeBitstringExtensions("extensions", 332),
        })
end

return ParameterTypeBitstring
