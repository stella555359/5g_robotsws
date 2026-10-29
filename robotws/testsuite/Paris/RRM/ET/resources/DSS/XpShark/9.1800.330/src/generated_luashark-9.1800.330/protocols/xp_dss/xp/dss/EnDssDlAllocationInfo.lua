-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_EnDssDlAllocationStartTime = require("xp/dss/EnDssDlAllocationStartTime")
local xp_dss_MbsfnSubframePattern = require("xp/dss/MbsfnSubframePattern")


-- The IE defines the allocation of MBSFN subframes and the start time, when the allocations gets valid.
function EnDssDlAllocationInfo (fieldName, position)
    return
        fields.Structure({name="EnDssDlAllocationInfo", fieldName=fieldName, position=position, size=12}, {
            fields.StaticVariableSizedArray({name="enDssDlAllocationStartTime", position=0, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_EnDssDlAllocationStartTime("enDssDlAllocationStartTime", 0)
            ),
            xp_dss_MbsfnSubframePattern("allocatedMbsfnSubframes", 8),
        })
end

return EnDssDlAllocationInfo
