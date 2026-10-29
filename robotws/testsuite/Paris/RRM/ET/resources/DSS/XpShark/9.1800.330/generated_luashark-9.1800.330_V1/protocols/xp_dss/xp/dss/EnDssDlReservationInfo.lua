-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_DlReservationInfo = require("xp/dss/DlReservationInfo"),
      xp_dss_EnDssDlReservationInfoExtensions = require("xp/dss/EnDssDlReservationInfoExtensions"),
}

function EnDssDlReservationInfo (fieldName, position)
    return
        fields.Structure({name="EnDssDlReservationInfo", fieldName=fieldName, position=position, size=280}, {
            localVarTable.xp_dss_DlReservationInfo("lte", 0),
            localVarTable.xp_dss_DlReservationInfo("nr", 136),
            localVarTable.xp_dss_EnDssDlReservationInfoExtensions("extensions", 272),
        })
end

return EnDssDlReservationInfo
