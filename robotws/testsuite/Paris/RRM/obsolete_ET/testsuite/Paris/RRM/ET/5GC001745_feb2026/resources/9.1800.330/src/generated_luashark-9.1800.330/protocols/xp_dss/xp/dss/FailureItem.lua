-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_FailureDescription = require("xp/dss/FailureDescription")
local xp_dss_FailureParameterInfo = require("xp/dss/FailureParameterInfo")
local xp_dss_FailureRecommendation = require("xp/dss/FailureRecommendation")


function FailureItem (fieldName, position)
    return
        fields.Structure({name="FailureItem", fieldName=fieldName, position=position, size=540}, {
            fields.uint32({name="failureId", position=0}),
            xp_dss_FailureDescription("description", 4),
            fields.StaticVariableSizedArray({name="descriptionAdditionalInfo", position=260, size=260, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_FailureDescription("descriptionAdditionalInfo", 260)
            ),
            fields.StaticVariableSizedArray({name="parameterInfo", position=520, size=12, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_FailureParameterInfo("parameterInfo", 520)
            ),
            fields.DynamicVariableSizedArray({name="recommendation", position=532, size=8, numSizePaddingBytes=0, numItems=5, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_dss_FailureRecommendation("recommendation", 532)
            ),
        })
end

return FailureItem
