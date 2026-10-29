-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern"),
      xp_dss_PrbAreas = require("xp/dss/PrbAreas"),
}

function DlReservationInfo (fieldName, position)
    return
        fields.Structure({name="DlReservationInfo", fieldName=fieldName, position=position, size=136}, {
            localVarTable.xp_dss_FixedSubframePattern("reservedMbsfnSubframes", 0),
            localVarTable.xp_dss_FixedSubframePattern("reservedNormalSubframes", 12),
            fields.StaticVariableSizedArray({name="reservedPrbs", position=24, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_PrbAreas("reservedPrbs", 24)
            ),
            fields.StaticVariableSizedArray({name="releasedPrbs", position=80, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_PrbAreas("releasedPrbs", 80)
            ),
        })
end

return DlReservationInfo
