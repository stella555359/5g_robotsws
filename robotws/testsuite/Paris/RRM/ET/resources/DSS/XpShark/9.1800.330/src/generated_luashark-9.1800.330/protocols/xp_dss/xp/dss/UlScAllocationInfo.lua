-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_EnDssDlAllocationStartTime = require("xp/dss/EnDssDlAllocationStartTime")
local xp_dss_PrbAreas = require("xp/dss/PrbAreas")
local xp_dss_UlScAllocationInfoExtensions = require("xp/dss/UlScAllocationInfoExtensions")


-- The IE defines the allocation of the normal subframes and the start time, when the allocations gets valid. It does not contain MBSFN subframe allocations. MBSFN subframes are reserved by a client during the cell DL coordinarion procedure and are not allocated by CRM in an allocation procedure.
function UlScAllocationInfo (fieldName, position)
    return
        fields.Structure({name="UlScAllocationInfo", fieldName=fieldName, position=position, size=64}, {
            xp_dss_EnDssDlAllocationStartTime("enDssUlAllocationStartTime", 0),
            xp_dss_PrbAreas("allocatedPrbs", 4),
            xp_dss_UlScAllocationInfoExtensions("extensions", 56),
        })
end

return UlScAllocationInfo
