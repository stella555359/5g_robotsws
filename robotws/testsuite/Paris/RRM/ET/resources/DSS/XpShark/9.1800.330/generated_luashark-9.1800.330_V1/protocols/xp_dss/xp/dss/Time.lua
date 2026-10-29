-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_TimeExtensions = require("xp/dss/TimeExtensions"),
}

function Time (fieldName, position)
    return
        fields.Structure({name="Time", fieldName=fieldName, position=position, size=16}, {
            fields.uint16({name="hyperframeNumber", position=0}),
            fields.uint16({name="systemFrameNumber", position=2}),
            fields.uint8({name="subframeNumber", position=4}),
            fields.Padding({name="subframeNumber_extensions_padding", position=5, size=3}),
            localVarTable.xp_dss_TimeExtensions("extensions", 8),
        })
end

return Time
