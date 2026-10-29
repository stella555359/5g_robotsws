-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlAllocationStartTime = require("xp/dss/EnDssDlAllocationStartTime"),
      xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern"),
      xp_dss_DlSfAllocationInfoExtensions = require("xp/dss/DlSfAllocationInfoExtensions"),
}

-- The IE defines the allocation of normal subframes and the start time, when the allocations gets valid.
function DlSfAllocationInfo (fieldName, position)
    return
        fields.Structure({name="DlSfAllocationInfo", fieldName=fieldName, position=position, size=28}, {
            localVarTable.xp_dss_EnDssDlAllocationStartTime("enDssDlAllocationStartTime", 0),
            fields.uint8({name="enDssDlAllocationPriority", position=4}),
            fields.Padding({name="enDssDlAllocationPriority_allocatedNormalSubframes_padding", position=5, size=3}),
            localVarTable.xp_dss_FixedSubframePattern("allocatedNormalSubframes", 8),
            localVarTable.xp_dss_DlSfAllocationInfoExtensions("extensions", 20),
        })
end

return DlSfAllocationInfo
