-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_PrbAreas = require("xp/dss/PrbAreas")


function UlReservationInfo (fieldName, position)
    return
        fields.Structure({name="UlReservationInfo", fieldName=fieldName, position=position, size=108}, {
            xp_dss_PrbAreas("reservedPrbs", 0),
            fields.StaticVariableSizedArray({name="releasedPrbs", position=52, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreas("releasedPrbs", 52)
            ),
        })
end

return UlReservationInfo
