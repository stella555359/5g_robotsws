-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_TimeExtensions = require("xp/dss/TimeExtensions")


function Time (fieldName, position)
    return
        fields.Structure({name="Time", fieldName=fieldName, position=position, size=16}, {
            fields.uint16({name="hyperframeNumber", position=0}),
            fields.uint16({name="systemFrameNumber", position=2}),
            fields.uint8({name="subframeNumber", position=4}),
            fields.Padding({name="subframeNumber_extensions_padding", position=5, size=3}),
            xp_dss_TimeExtensions("extensions", 8),
        })
end

return Time
