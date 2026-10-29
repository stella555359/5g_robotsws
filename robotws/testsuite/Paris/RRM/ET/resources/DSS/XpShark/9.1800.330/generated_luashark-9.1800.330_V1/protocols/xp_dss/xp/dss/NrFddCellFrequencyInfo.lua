-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_NrFddCellFrequencyInfoExtensions = require("xp/dss/NrFddCellFrequencyInfoExtensions"),
}

function NrFddCellFrequencyInfo (fieldName, position)
    return
        fields.Structure({name="NrFddCellFrequencyInfo", fieldName=fieldName, position=position, size=28}, {
            fields.uint16({name="nrDlTransmissionBandwidth", position=0}),
            fields.Padding({name="nrDlTransmissionBandwidth_nrArfcnDl_padding", position=2, size=2}),
            fields.uint32({name="nrArfcnDl", position=4}),
            fields.uint16({name="nrDlSubCarrierSpacing", position=8}),
            fields.uint16({name="nrUlTransmissionBandwidth", position=10}),
            fields.uint32({name="nrArfcnUl", position=12}),
            fields.uint16({name="nrUlSubCarrierSpacing", position=16}),
            fields.Padding({name="nrUlSubCarrierSpacing_extensions_padding", position=18, size=2}),
            localVarTable.xp_dss_NrFddCellFrequencyInfoExtensions("extensions", 20),
        })
end

return NrFddCellFrequencyInfo
