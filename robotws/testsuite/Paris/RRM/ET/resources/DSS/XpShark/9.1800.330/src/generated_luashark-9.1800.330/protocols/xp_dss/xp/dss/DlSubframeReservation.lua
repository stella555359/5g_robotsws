-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
