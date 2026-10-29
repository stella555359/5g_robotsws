-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_NrFddDlCellFrequencyInfoExtensions = require("xp/dss/NrFddDlCellFrequencyInfoExtensions"),
}

function NrFddDlCellFrequencyInfo (fieldName, position)
    return
        fields.Structure({name="NrFddDlCellFrequencyInfo", fieldName=fieldName, position=position, size=20}, {
            fields.uint16({name="nrDlTransmissionBandwidth", position=0}),
            fields.Padding({name="nrDlTransmissionBandwidth_nrArfcnDl_padding", position=2, size=2}),
            fields.uint32({name="nrArfcnDl", position=4}),
            fields.uint16({name="nrDlSubCarrierSpacing", position=8}),
            fields.Padding({name="nrDlSubCarrierSpacing_extensions_padding", position=10, size=2}),
            localVarTable.xp_dss_NrFddDlCellFrequencyInfoExtensions("extensions", 12),
        })
end

return NrFddDlCellFrequencyInfo
