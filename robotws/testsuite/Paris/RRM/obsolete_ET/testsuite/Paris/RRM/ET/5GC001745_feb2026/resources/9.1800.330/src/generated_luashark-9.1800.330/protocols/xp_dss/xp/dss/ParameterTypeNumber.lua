-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_FailureDescription = require("xp/dss/FailureDescription")
local xp_dss_NumberParameterValues = require("xp/dss/NumberParameterValues")
local xp_dss_ParameterTypeNumberExtensions = require("xp/dss/ParameterTypeNumberExtensions")


function ParameterTypeNumber (fieldName, position)
    return
        fields.Structure({name="ParameterTypeNumber", fieldName=fieldName, position=position, size=284}, {
            xp_dss_FailureDescription("parameterName", 0),
            fields.uint32({name="parameterValueLength", position=256}),
            fields.DynamicVariableSizedArray({name="parameterValues", position=260, size=8, numSizePaddingBytes=0, numItems=6, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_dss_NumberParameterValues("parameterValues", 260)
            ),
            fields.DynamicVariableSizedArray({name="conflictingValues", position=268, size=8, numSizePaddingBytes=0, numItems=20, numPaddingBytes=0},
                fields.uint32, fields.uint32, fields.int32({name="item", position=268})
            ),
            xp_dss_ParameterTypeNumberExtensions("extensions", 276),
        })
end

return ParameterTypeNumber
