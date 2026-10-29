-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_UlReservationInfo = require("xp/dss/UlReservationInfo"),
      xp_dss_EnDssUlReservationInfoExtensions = require("xp/dss/EnDssUlReservationInfoExtensions"),
}

-- This info element is used e.g. in the EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION RESPONSE message or EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION UPDATE INDICATION message.
--      It allows in failure cases to identify the exact position of reservation conflicts (e.g. in EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION FAILURE and EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION FAILURE INFO.
function EnDssUlReservationInfo (fieldName, position)
    return
        fields.Structure({name="EnDssUlReservationInfo", fieldName=fieldName, position=position, size=224}, {
            localVarTable.xp_dss_UlReservationInfo("lte", 0),
            localVarTable.xp_dss_UlReservationInfo("nr", 108),
            localVarTable.xp_dss_EnDssUlReservationInfoExtensions("extensions", 216),
        })
end

return EnDssUlReservationInfo
