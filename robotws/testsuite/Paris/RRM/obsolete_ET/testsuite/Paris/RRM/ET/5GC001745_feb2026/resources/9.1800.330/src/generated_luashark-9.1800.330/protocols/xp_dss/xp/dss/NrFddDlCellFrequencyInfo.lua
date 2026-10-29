-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_NrFddDlCellFrequencyInfoExtensions = require("xp/dss/NrFddDlCellFrequencyInfoExtensions")


function NrFddDlCellFrequencyInfo (fieldName, position)
    return
        fields.Structure({name="NrFddDlCellFrequencyInfo", fieldName=fieldName, position=position, size=20}, {
            fields.uint16({name="nrDlTransmissionBandwidth", position=0}),
            fields.Padding({name="nrDlTransmissionBandwidth_nrArfcnDl_padding", position=2, size=2}),
            fields.uint32({name="nrArfcnDl", position=4}),
            fields.uint16({name="nrDlSubCarrierSpacing", position=8}),
            fields.Padding({name="nrDlSubCarrierSpacing_extensions_padding", position=10, size=2}),
            xp_dss_NrFddDlCellFrequencyInfoExtensions("extensions", 12),
        })
end

return NrFddDlCellFrequencyInfo
