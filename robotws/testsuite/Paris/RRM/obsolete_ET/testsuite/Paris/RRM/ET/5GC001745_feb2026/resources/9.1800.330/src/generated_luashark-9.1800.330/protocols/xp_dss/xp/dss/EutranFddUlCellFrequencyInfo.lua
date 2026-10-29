-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
