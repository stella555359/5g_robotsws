-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
