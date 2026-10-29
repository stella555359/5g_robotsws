-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
