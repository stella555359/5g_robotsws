-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EutranFddUlCellFrequencyInfo = require("xp/dss/EutranFddUlCellFrequencyInfo"),
      xp_dss_NrFddUlCellFrequencyInfo = require("xp/dss/NrFddUlCellFrequencyInfo"),
}

-- This IE defines the DL frequency characteristics of the two involved cells. DSS is only permitted, if the center frequency of the carriers, the bandwidth and the subcarrier spacing are comparable.
function FddUlCellFrequencyInfo (fieldName, position)
    return
        fields.DynamicUnion({name="FddUlCellFrequencyInfo", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            localVarTable.xp_dss_EutranFddUlCellFrequencyInfo("eutranFddUlCellFrequencyInfo", 0),
            localVarTable.xp_dss_NrFddUlCellFrequencyInfo("nrFddUlCellFrequencyInfo", 0),
            },
            {0, 1, 2}
        )
end

return FddUlCellFrequencyInfo
