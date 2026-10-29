-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
