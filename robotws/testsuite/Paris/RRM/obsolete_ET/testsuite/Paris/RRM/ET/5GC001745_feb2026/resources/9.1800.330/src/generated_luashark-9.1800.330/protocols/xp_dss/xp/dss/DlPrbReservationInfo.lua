-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_DlPrbReservationInfoItem = require("xp/dss/DlPrbReservationInfoItem")
local xp_dss_DlPrbReservationInfoExtensions = require("xp/dss/DlPrbReservationInfoExtensions")


function DlPrbReservationInfo (fieldName, position)
    return
        fields.Structure({name="DlPrbReservationInfo", fieldName=fieldName, position=position, size=80}, {
            xp_dss_DlPrbReservationInfoItem("lte", 0),
            xp_dss_DlPrbReservationInfoItem("nr", 36),
            xp_dss_DlPrbReservationInfoExtensions("extensions", 72),
        })
end

return DlPrbReservationInfo
