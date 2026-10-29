-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlAllocationStartTime = require("xp/dss/EnDssDlAllocationStartTime"),
      xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern"),
      xp_dss_PrbAreaAllocationList = require("xp/dss/PrbAreaAllocationList"),
      xp_dss_DlPrbAllocationInfoExtensions = require("xp/dss/DlPrbAllocationInfoExtensions"),
}

-- The IE defines the allocation of the normal subframes, the Symbol 1 usage for PDCCH, Resource areas  and the start time, when the allocations gets valid.
--      It does not contain MBSFN subframe allocations.
--      MBSFN subframes are reserved by a client during the cell DL coordination procedure and are not allocated by CRM in an allocation procedure.
function DlPrbAllocationInfo (fieldName, position)
    return
        fields.Structure({name="DlPrbAllocationInfo", fieldName=fieldName, position=position, size=996}, {
            localVarTable.xp_dss_EnDssDlAllocationStartTime("enDssDlAllocationStartTime", 0),
            fields.uint8({name="enDssDlAllocationPriority", position=4}),
            fields.Padding({name="enDssDlAllocationPriority_allocatedNormalSubframes_padding", position=5, size=3}),
            localVarTable.xp_dss_FixedSubframePattern("allocatedNormalSubframes", 8),
            fields.StaticVariableSizedArray({name="prbAreaAllocationList", position=20, size=968, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_PrbAreaAllocationList("prbAreaAllocationList", 20)
            ),
            localVarTable.xp_dss_DlPrbAllocationInfoExtensions("extensions", 988),
        })
end

return DlPrbAllocationInfo
