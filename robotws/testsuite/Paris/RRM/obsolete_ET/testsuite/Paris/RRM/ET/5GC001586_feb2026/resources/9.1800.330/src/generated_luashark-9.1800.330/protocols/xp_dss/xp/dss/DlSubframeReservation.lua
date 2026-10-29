-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern")
local xp_dss_PeriodicNormalSubframes = require("xp/dss/PeriodicNormalSubframes")
local xp_dss_DlSubframeReservationExtensions = require("xp/dss/DlSubframeReservationExtensions")


function DlSubframeReservation (fieldName, position)
    return
        fields.Structure({name="DlSubframeReservation", fieldName=fieldName, position=position, size=120}, {
            xp_dss_FixedSubframePattern("fixedMbsfnSubframes", 0),
            xp_dss_FixedSubframePattern("fixedNormalSubframes", 12),
            fields.StaticVariableSizedArray({name="periodicNormalSubframes", position=24, size=88, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PeriodicNormalSubframes("periodicNormalSubframes", 24)
            ),
            xp_dss_DlSubframeReservationExtensions("extensions", 112),
        })
end

return DlSubframeReservation
