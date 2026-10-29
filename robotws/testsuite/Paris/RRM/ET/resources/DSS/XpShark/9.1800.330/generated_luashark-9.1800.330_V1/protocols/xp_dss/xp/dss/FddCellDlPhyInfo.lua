-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_FddDlCellFrequencyInfo = require("xp/dss/FddDlCellFrequencyInfo"),
      xp_dss_NumberOfTxAntennaPorts = require("xp/dss/NumberOfTxAntennaPorts"),
      xp_dss_FddCellDlPhyInfoExtensions = require("xp/dss/FddCellDlPhyInfoExtensions"),
}

-- This IE defines parameters that are used for the Common Resource Management algorithm in the CRM.
function FddCellDlPhyInfo (fieldName, position)
    return
        fields.Structure({name="FddCellDlPhyInfo", fieldName=fieldName, position=position, size=24}, {
            localVarTable.xp_dss_FddDlCellFrequencyInfo("fddDlCellFrequencyInfo", 0),
            fields.uint16({name="ltePhysicalCellId", position=8}),
            fields.Padding({name="ltePhysicalCellId_numberOfTxAntennaPorts_padding", position=10, size=2}),
            fields.enumeration(
                {name="numberOfTxAntennaPorts", position=12, enumTerm=localVarTable.xp_dss_NumberOfTxAntennaPorts},
                ProtoField.int32, 4, "int32"),
            localVarTable.xp_dss_FddCellDlPhyInfoExtensions("extensions", 16),
        })
end

return FddCellDlPhyInfo
