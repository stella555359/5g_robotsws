-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EutranFddCellFrequencyInfo = require("xp/dss/EutranFddCellFrequencyInfo"),
      xp_dss_NrFddCellFrequencyInfo = require("xp/dss/NrFddCellFrequencyInfo"),
}

-- This IE defines the frequency characteristics of the two involved cells. DSS is only permitted, if the center frequency of the carriers, the bandwidth and the subcarrier spacing are comparable.
function FddCellFrequencyInfo (fieldName, position)
    return
        fields.DynamicUnion({name="FddCellFrequencyInfo", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            localVarTable.xp_dss_EutranFddCellFrequencyInfo("eutranFddCellFrequencyInfo", 0),
            localVarTable.xp_dss_NrFddCellFrequencyInfo("nrFddCellFrequencyInfo", 0),
            },
            {0, 1, 2}
        )
end

return FddCellFrequencyInfo
