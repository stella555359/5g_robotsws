-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EutranFddCellFrequencyInfoExtensions = require("xp/dss/EutranFddCellFrequencyInfoExtensions"),
}

function EutranFddCellFrequencyInfo (fieldName, position)
    return
        fields.Structure({name="EutranFddCellFrequencyInfo", fieldName=fieldName, position=position, size=24}, {
            fields.uint16({name="eutranDlTransmissionBandwidth", position=0}),
            fields.Padding({name="eutranDlTransmissionBandwidth_earfcnDl_padding", position=2, size=2}),
            fields.uint32({name="earfcnDl", position=4}),
            fields.uint16({name="eutranUlTransmissionBandwidth", position=8}),
            fields.Padding({name="eutranUlTransmissionBandwidth_earfcnUl_padding", position=10, size=2}),
            fields.uint32({name="earfcnUl", position=12}),
            localVarTable.xp_dss_EutranFddCellFrequencyInfoExtensions("extensions", 16),
        })
end

return EutranFddCellFrequencyInfo
