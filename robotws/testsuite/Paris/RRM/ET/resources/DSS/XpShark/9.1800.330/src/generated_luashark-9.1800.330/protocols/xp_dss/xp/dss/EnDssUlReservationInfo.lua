-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_UlReservationInfo = require("xp/dss/UlReservationInfo")
local xp_dss_EnDssUlReservationInfoExtensions = require("xp/dss/EnDssUlReservationInfoExtensions")


-- This info element is used e.g. in the EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION RESPONSE message or EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION UPDATE INDICATION message.
--      It allows in failure cases to identify the exact position of reservation conflicts (e.g. in EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION FAILURE and EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION FAILURE INFO.
function EnDssUlReservationInfo (fieldName, position)
    return
        fields.Structure({name="EnDssUlReservationInfo", fieldName=fieldName, position=position, size=224}, {
            xp_dss_UlReservationInfo("lte", 0),
            xp_dss_UlReservationInfo("nr", 108),
            xp_dss_EnDssUlReservationInfoExtensions("extensions", 216),
        })
end

return EnDssUlReservationInfo
