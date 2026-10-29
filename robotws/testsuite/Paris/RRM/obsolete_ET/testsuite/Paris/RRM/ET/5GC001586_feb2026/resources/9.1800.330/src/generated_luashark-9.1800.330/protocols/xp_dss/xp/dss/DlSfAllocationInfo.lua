-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_EnDssDlAllocationStartTime = require("xp/dss/EnDssDlAllocationStartTime")
local xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern")
local xp_dss_DlSfAllocationInfoExtensions = require("xp/dss/DlSfAllocationInfoExtensions")


-- The IE defines the allocation of normal subframes and the start time, when the allocations gets valid.
function DlSfAllocationInfo (fieldName, position)
    return
        fields.Structure({name="DlSfAllocationInfo", fieldName=fieldName, position=position, size=28}, {
            xp_dss_EnDssDlAllocationStartTime("enDssDlAllocationStartTime", 0),
            fields.uint8({name="enDssDlAllocationPriority", position=4}),
            fields.Padding({name="enDssDlAllocationPriority_allocatedNormalSubframes_padding", position=5, size=3}),
            xp_dss_FixedSubframePattern("allocatedNormalSubframes", 8),
            xp_dss_DlSfAllocationInfoExtensions("extensions", 20),
        })
end

return DlSfAllocationInfo
