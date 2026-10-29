-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern")
local xp_dss_CatmAllocInfoExtensions = require("xp/dss/CatmAllocInfoExtensions")


function CatmAllocInfo (fieldName, position)
    return
        fields.Structure({name="CatmAllocInfo", fieldName=fieldName, position=position, size=60}, {
            xp_dss_FixedSubframePattern("prbArea_A_forSib1BrSubframes", 0),
            xp_dss_FixedSubframePattern("prbArea_B_forSib1BrSubframes", 12),
            fields.DynamicVariableSizedArray({name="prbArea_C_forSib1BrSubframes", position=24, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_dss_FixedSubframePattern("prbArea_C_forSib1BrSubframes", 24)
            ),
            fields.DynamicVariableSizedArray({name="prbArea_D_forSib1BrSubframes", position=32, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_dss_FixedSubframePattern("prbArea_D_forSib1BrSubframes", 32)
            ),
            xp_dss_FixedSubframePattern("prbAreaForCatmPagingSubframes", 40),
            xp_dss_CatmAllocInfoExtensions("extensions", 52),
        })
end

return CatmAllocInfo
