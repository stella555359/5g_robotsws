-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
