-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EutranFddDlCellFrequencyInfoExtensions = require("xp/dss/EutranFddDlCellFrequencyInfoExtensions")


function EutranFddDlCellFrequencyInfo (fieldName, position)
    return
        fields.Structure({name="EutranFddDlCellFrequencyInfo", fieldName=fieldName, position=position, size=16}, {
            fields.uint16({name="eutranDlTransmissionBandwidth", position=0}),
            fields.Padding({name="eutranDlTransmissionBandwidth_earfcnDl_padding", position=2, size=2}),
            fields.uint32({name="earfcnDl", position=4}),
            xp_dss_EutranFddDlCellFrequencyInfoExtensions("extensions", 8),
        })
end

return EutranFddDlCellFrequencyInfo
