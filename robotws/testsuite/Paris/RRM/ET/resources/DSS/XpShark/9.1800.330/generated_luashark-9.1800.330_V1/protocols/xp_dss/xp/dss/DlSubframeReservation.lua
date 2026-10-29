-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern"),
      xp_dss_PeriodicNormalSubframes = require("xp/dss/PeriodicNormalSubframes"),
      xp_dss_DlSubframeReservationExtensions = require("xp/dss/DlSubframeReservationExtensions"),
}

function DlSubframeReservation (fieldName, position)
    return
        fields.Structure({name="DlSubframeReservation", fieldName=fieldName, position=position, size=120}, {
            localVarTable.xp_dss_FixedSubframePattern("fixedMbsfnSubframes", 0),
            localVarTable.xp_dss_FixedSubframePattern("fixedNormalSubframes", 12),
            fields.StaticVariableSizedArray({name="periodicNormalSubframes", position=24, size=88, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_PeriodicNormalSubframes("periodicNormalSubframes", 24)
            ),
            localVarTable.xp_dss_DlSubframeReservationExtensions("extensions", 112),
        })
end

return DlSubframeReservation
