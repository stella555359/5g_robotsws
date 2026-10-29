-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_CatmInfo = require("xp/dss/CatmInfo")
local xp_dss_DlPrbReservationInfoExtension1Extensions = require("xp/dss/DlPrbReservationInfoExtension1Extensions")


function DlPrbReservationInfoExtension1 (fieldName, position)
    return
        fields.Structure({name="DlPrbReservationInfoExtension1", fieldName=fieldName, position=position, size=24}, {
            xp_dss_CatmInfo("catmInfo", 0),
            xp_dss_DlPrbReservationInfoExtension1Extensions("extensions", 16),
        })
end

return DlPrbReservationInfoExtension1
