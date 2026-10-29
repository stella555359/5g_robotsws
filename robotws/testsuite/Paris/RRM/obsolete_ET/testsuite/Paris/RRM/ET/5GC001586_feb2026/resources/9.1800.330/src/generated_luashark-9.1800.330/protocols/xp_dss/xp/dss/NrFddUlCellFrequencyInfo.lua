-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_NrFddUlCellFrequencyInfoExtensions = require("xp/dss/NrFddUlCellFrequencyInfoExtensions")


function NrFddUlCellFrequencyInfo (fieldName, position)
    return
        fields.Structure({name="NrFddUlCellFrequencyInfo", fieldName=fieldName, position=position, size=20}, {
            fields.uint16({name="nrUlTransmissionBandwidth", position=0}),
            fields.Padding({name="nrUlTransmissionBandwidth_nrArfcnUl_padding", position=2, size=2}),
            fields.uint32({name="nrArfcnUl", position=4}),
            fields.uint16({name="nrUlSubCarrierSpacing", position=8}),
            fields.Padding({name="nrUlSubCarrierSpacing_extensions_padding", position=10, size=2}),
            xp_dss_NrFddUlCellFrequencyInfoExtensions("extensions", 12),
        })
end

return NrFddUlCellFrequencyInfo
