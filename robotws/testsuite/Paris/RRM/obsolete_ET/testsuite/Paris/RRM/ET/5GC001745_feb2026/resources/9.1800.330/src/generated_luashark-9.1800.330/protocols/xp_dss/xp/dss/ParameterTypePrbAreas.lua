-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_FailureDescription = require("xp/dss/FailureDescription")
local xp_dss_PrbAreas = require("xp/dss/PrbAreas")
local xp_dss_ParameterTypePrbAreasExtensions = require("xp/dss/ParameterTypePrbAreasExtensions")


function ParameterTypePrbAreas (fieldName, position)
    return
        fields.Structure({name="ParameterTypePrbAreas", fieldName=fieldName, position=position, size=376}, {
            xp_dss_FailureDescription("parameterName", 0),
            fields.StaticVariableSizedArray({name="parameterValueLte", position=256, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreas("parameterValueLte", 256)
            ),
            fields.StaticVariableSizedArray({name="parameterValueNr", position=312, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreas("parameterValueNr", 312)
            ),
            xp_dss_ParameterTypePrbAreasExtensions("extensions", 368),
        })
end

return ParameterTypePrbAreas
