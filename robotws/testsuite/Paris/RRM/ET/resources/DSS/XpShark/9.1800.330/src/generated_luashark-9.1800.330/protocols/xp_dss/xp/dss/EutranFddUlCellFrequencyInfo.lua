-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_EutranFddUlCellFrequencyInfoExtensions = require("xp/dss/EutranFddUlCellFrequencyInfoExtensions")


function EutranFddUlCellFrequencyInfo (fieldName, position)
    return
        fields.Structure({name="EutranFddUlCellFrequencyInfo", fieldName=fieldName, position=position, size=16}, {
            fields.uint16({name="eutranUlTransmissionBandwidth", position=0}),
            fields.Padding({name="eutranUlTransmissionBandwidth_earfcnUl_padding", position=2, size=2}),
            fields.uint32({name="earfcnUl", position=4}),
            xp_dss_EutranFddUlCellFrequencyInfoExtensions("extensions", 8),
        })
end

return EutranFddUlCellFrequencyInfo
