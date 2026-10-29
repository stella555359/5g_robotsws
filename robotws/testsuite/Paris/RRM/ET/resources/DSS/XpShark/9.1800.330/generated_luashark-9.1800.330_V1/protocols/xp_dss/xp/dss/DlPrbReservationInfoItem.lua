-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern"),
      xp_dss_PrbAreaCoordinationList = require("xp/dss/PrbAreaCoordinationList"),
}

function DlPrbReservationInfoItem (fieldName, position)
    return
        fields.Structure({name="DlPrbReservationInfoItem", fieldName=fieldName, position=position, size=36}, {
            localVarTable.xp_dss_FixedSubframePattern("reservedMbsfnSubframes", 0),
            fields.StaticVariableSizedArray({name="reservedPrbAreaCoordinationList", position=12, size=12, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_PrbAreaCoordinationList("reservedPrbAreaCoordinationList", 12)
            ),
            fields.StaticVariableSizedArray({name="releasedPrbAreaCoordinationList", position=24, size=12, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_PrbAreaCoordinationList("releasedPrbAreaCoordinationList", 24)
            ),
        })
end

return DlPrbReservationInfoItem
