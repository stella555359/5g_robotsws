-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
