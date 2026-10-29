-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_FddDlCellFrequencyInfo = require("xp/dss/FddDlCellFrequencyInfo")
local xp_dss_NumberOfTxAntennaPorts = require("xp/dss/NumberOfTxAntennaPorts")
local xp_dss_FddCellDlPhyInfoExtensions = require("xp/dss/FddCellDlPhyInfoExtensions")


-- This IE defines parameters that are used for the Common Resource Management algorithm in the CRM.
function FddCellDlPhyInfo (fieldName, position)
    return
        fields.Structure({name="FddCellDlPhyInfo", fieldName=fieldName, position=position, size=24}, {
            xp_dss_FddDlCellFrequencyInfo("fddDlCellFrequencyInfo", 0),
            fields.uint16({name="ltePhysicalCellId", position=8}),
            fields.Padding({name="ltePhysicalCellId_numberOfTxAntennaPorts_padding", position=10, size=2}),
            fields.enumeration(
                {name="numberOfTxAntennaPorts", position=12, enumTerm=xp_dss_NumberOfTxAntennaPorts},
                ProtoField.int32, 4, "int32"),
            xp_dss_FddCellDlPhyInfoExtensions("extensions", 16),
        })
end

return FddCellDlPhyInfo
