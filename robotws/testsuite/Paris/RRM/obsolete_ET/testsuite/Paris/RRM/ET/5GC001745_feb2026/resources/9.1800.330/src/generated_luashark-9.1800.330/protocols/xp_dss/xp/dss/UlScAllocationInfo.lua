-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
