-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
