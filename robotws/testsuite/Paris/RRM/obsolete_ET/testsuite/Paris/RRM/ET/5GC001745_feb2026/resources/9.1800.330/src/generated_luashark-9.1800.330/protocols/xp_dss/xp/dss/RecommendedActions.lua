-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_ActionItem = require("xp/dss/ActionItem")


function RecommendedActions (fieldName, position)
    return
        fields.Structure({name="RecommendedActions", fieldName=fieldName, position=position, size=48}, {
            fields.uint32({name="actionName", position=0}),
            fields.StaticVariableSizedArray({name="actionItem", position=4, size=44, numSizePaddingBytes=0, numItems=5, numPaddingBytes=0},
                fields.uint32, xp_dss_ActionItem("actionItem", 4)
            ),
        })
end

return RecommendedActions
