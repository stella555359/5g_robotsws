-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
