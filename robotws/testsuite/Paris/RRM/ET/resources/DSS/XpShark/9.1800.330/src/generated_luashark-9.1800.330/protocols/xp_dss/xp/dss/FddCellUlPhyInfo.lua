-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_FddUlCellFrequencyInfo = require("xp/dss/FddUlCellFrequencyInfo")
local xp_dss_FddCellUlPhyInfoExtensions = require("xp/dss/FddCellUlPhyInfoExtensions")


-- This IE defines parameters that are used for the Common Resource Management algorithm in the CRM.
function FddCellUlPhyInfo (fieldName, position)
    return
        fields.Structure({name="FddCellUlPhyInfo", fieldName=fieldName, position=position, size=16}, {
            xp_dss_FddUlCellFrequencyInfo("fddUlCellFrequencyInfo", 0),
            xp_dss_FddCellUlPhyInfoExtensions("extensions", 8),
        })
end

return FddCellUlPhyInfo
