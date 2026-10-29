-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
