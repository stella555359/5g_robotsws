-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
