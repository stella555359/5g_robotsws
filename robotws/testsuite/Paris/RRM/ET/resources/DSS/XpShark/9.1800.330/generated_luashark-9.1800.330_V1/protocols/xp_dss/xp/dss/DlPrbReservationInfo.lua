-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_DlPrbReservationInfoItem = require("xp/dss/DlPrbReservationInfoItem"),
      xp_dss_DlPrbReservationInfoExtensions = require("xp/dss/DlPrbReservationInfoExtensions"),
}

function DlPrbReservationInfo (fieldName, position)
    return
        fields.Structure({name="DlPrbReservationInfo", fieldName=fieldName, position=position, size=80}, {
            localVarTable.xp_dss_DlPrbReservationInfoItem("lte", 0),
            localVarTable.xp_dss_DlPrbReservationInfoItem("nr", 36),
            localVarTable.xp_dss_DlPrbReservationInfoExtensions("extensions", 72),
        })
end

return DlPrbReservationInfo
