-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
