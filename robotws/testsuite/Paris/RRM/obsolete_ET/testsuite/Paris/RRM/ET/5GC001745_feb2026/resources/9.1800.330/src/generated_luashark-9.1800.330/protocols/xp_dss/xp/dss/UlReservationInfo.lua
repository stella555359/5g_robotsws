-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
