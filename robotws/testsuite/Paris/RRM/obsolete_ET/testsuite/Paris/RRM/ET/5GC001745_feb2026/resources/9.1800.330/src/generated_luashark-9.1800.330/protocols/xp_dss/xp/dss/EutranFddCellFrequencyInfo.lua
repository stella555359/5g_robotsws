-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
