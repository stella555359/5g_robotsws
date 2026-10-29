-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_EutranFddCellFrequencyInfoExtensions = require("xp/dss/EutranFddCellFrequencyInfoExtensions")


function EutranFddCellFrequencyInfo (fieldName, position)
    return
        fields.Structure({name="EutranFddCellFrequencyInfo", fieldName=fieldName, position=position, size=24}, {
            fields.uint16({name="eutranDlTransmissionBandwidth", position=0}),
            fields.Padding({name="eutranDlTransmissionBandwidth_earfcnDl_padding", position=2, size=2}),
            fields.uint32({name="earfcnDl", position=4}),
            fields.uint16({name="eutranUlTransmissionBandwidth", position=8}),
            fields.Padding({name="eutranUlTransmissionBandwidth_earfcnUl_padding", position=10, size=2}),
            fields.uint32({name="earfcnUl", position=12}),
            xp_dss_EutranFddCellFrequencyInfoExtensions("extensions", 16),
        })
end

return EutranFddCellFrequencyInfo
