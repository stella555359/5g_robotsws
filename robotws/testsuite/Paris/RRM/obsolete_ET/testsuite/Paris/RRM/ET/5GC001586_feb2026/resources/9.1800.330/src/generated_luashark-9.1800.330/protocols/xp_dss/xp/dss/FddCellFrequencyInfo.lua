-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_EutranFddCellFrequencyInfo = require("xp/dss/EutranFddCellFrequencyInfo")
local xp_dss_NrFddCellFrequencyInfo = require("xp/dss/NrFddCellFrequencyInfo")


-- This IE defines the frequency characteristics of the two involved cells. DSS is only permitted, if the center frequency of the carriers, the bandwidth and the subcarrier spacing are comparable.
function FddCellFrequencyInfo (fieldName, position)
    return
        fields.DynamicUnion({name="FddCellFrequencyInfo", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_dss_EutranFddCellFrequencyInfo("eutranFddCellFrequencyInfo", 0),
            xp_dss_NrFddCellFrequencyInfo("nrFddCellFrequencyInfo", 0),
            },
            {0, 1, 2}
        )
end

return FddCellFrequencyInfo
