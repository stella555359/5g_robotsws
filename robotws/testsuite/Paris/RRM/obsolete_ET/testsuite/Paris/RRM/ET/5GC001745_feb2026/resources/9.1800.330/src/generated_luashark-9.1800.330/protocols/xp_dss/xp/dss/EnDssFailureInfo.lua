-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_FailureInfoItem = require("xp/dss/FailureInfoItem")
local xp_dss_EnDssFailureInfoExtensions = require("xp/dss/EnDssFailureInfoExtensions")


function EnDssFailureInfo (fieldName, position)
    return
        fields.Structure({name="EnDssFailureInfo", fieldName=fieldName, position=position, size=16}, {
            fields.DynamicVariableSizedArray({name="failureInfo", position=0, size=8, numSizePaddingBytes=0, numItems=5, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_dss_FailureInfoItem("failureInfo", 0)
            ),
            xp_dss_EnDssFailureInfoExtensions("extensions", 8),
        })
end

return EnDssFailureInfo
