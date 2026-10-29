-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
