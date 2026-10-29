-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
