-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
