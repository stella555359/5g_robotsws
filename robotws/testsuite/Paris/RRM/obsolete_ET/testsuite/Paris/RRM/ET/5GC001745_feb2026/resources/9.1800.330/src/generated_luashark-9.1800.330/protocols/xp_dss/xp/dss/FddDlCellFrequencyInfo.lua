-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EutranFddDlCellFrequencyInfo = require("xp/dss/EutranFddDlCellFrequencyInfo")
local xp_dss_NrFddDlCellFrequencyInfo = require("xp/dss/NrFddDlCellFrequencyInfo")


-- This IE defines the frequency characteristics of the two involved cells. DSS is only permitted, if the center frequency of the carriers, the bandwidth and the subcarrier spacing are comparable.
function FddDlCellFrequencyInfo (fieldName, position)
    return
        fields.DynamicUnion({name="FddDlCellFrequencyInfo", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_dss_EutranFddDlCellFrequencyInfo("eutranFddDlCellFrequencyInfo", 0),
            xp_dss_NrFddDlCellFrequencyInfo("nrFddDlCellFrequencyInfo", 0),
            },
            {0, 1, 2}
        )
end

return FddDlCellFrequencyInfo
