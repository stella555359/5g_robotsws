-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlAllocationStartTime = require("xp/dss/EnDssDlAllocationStartTime"),
      xp_dss_PrbAreas = require("xp/dss/PrbAreas"),
      xp_dss_UlScAllocationInfoExtensions = require("xp/dss/UlScAllocationInfoExtensions"),
}

-- The IE defines the allocation of the normal subframes and the start time, when the allocations gets valid. It does not contain MBSFN subframe allocations. MBSFN subframes are reserved by a client during the cell DL coordinarion procedure and are not allocated by CRM in an allocation procedure.
function UlScAllocationInfo (fieldName, position)
    return
        fields.Structure({name="UlScAllocationInfo", fieldName=fieldName, position=position, size=64}, {
            localVarTable.xp_dss_EnDssDlAllocationStartTime("enDssUlAllocationStartTime", 0),
            localVarTable.xp_dss_PrbAreas("allocatedPrbs", 4),
            localVarTable.xp_dss_UlScAllocationInfoExtensions("extensions", 56),
        })
end

return UlScAllocationInfo
