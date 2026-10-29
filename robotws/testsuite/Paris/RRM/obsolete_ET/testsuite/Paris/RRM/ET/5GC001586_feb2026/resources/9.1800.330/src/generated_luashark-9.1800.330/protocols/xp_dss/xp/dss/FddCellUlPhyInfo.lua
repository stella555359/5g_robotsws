-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
