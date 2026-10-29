-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
