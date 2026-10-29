-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_DlReservationInfo = require("xp/dss/DlReservationInfo")
local xp_dss_EnDssDlReservationInfoExtensions = require("xp/dss/EnDssDlReservationInfoExtensions")


function EnDssDlReservationInfo (fieldName, position)
    return
        fields.Structure({name="EnDssDlReservationInfo", fieldName=fieldName, position=position, size=280}, {
            xp_dss_DlReservationInfo("lte", 0),
            xp_dss_DlReservationInfo("nr", 136),
            xp_dss_EnDssDlReservationInfoExtensions("extensions", 272),
        })
end

return EnDssDlReservationInfo
