-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
