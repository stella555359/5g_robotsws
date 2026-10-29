-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_FailureDescription = require("xp/dss/FailureDescription")
local xp_dss_ParameterTypeStringExtensions = require("xp/dss/ParameterTypeStringExtensions")


function ParameterTypeString (fieldName, position)
    return
        fields.Structure({name="ParameterTypeString", fieldName=fieldName, position=position, size=1044}, {
            xp_dss_FailureDescription("parameterName", 0),
            fields.StaticVariableSizedArray({name="parameterValueLte", position=256, size=260, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_FailureDescription("parameterValueLte", 256)
            ),
            fields.StaticVariableSizedArray({name="parameterValueNr", position=516, size=260, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_FailureDescription("parameterValueNr", 516)
            ),
            fields.StaticVariableSizedArray({name="description", position=776, size=260, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_FailureDescription("description", 776)
            ),
            xp_dss_ParameterTypeStringExtensions("extensions", 1036),
        })
end

return ParameterTypeString
