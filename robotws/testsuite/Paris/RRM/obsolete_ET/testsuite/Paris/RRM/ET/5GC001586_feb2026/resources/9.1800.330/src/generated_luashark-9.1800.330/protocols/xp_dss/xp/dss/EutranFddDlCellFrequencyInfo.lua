-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
