-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern")
local xp_dss_PrbAreas = require("xp/dss/PrbAreas")


function DlReservationInfo (fieldName, position)
    return
        fields.Structure({name="DlReservationInfo", fieldName=fieldName, position=position, size=136}, {
            xp_dss_FixedSubframePattern("reservedMbsfnSubframes", 0),
            xp_dss_FixedSubframePattern("reservedNormalSubframes", 12),
            fields.StaticVariableSizedArray({name="reservedPrbs", position=24, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreas("reservedPrbs", 24)
            ),
            fields.StaticVariableSizedArray({name="releasedPrbs", position=80, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreas("releasedPrbs", 80)
            ),
        })
end

return DlReservationInfo
