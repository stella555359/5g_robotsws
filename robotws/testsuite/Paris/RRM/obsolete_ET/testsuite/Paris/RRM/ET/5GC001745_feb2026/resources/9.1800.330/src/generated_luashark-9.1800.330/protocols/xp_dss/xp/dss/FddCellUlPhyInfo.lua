-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
