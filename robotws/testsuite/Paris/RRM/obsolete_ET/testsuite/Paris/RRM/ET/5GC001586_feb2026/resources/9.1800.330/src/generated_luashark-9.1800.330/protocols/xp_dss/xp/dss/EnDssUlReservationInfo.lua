-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
