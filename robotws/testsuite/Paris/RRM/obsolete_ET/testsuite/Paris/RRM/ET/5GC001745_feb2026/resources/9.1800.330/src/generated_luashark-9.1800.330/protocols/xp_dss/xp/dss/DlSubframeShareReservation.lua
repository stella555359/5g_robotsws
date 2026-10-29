-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_DlSubframeShareReservationExtensions = require("xp/dss/DlSubframeShareReservationExtensions")


function DlSubframeShareReservation (fieldName, position)
    return
        fields.Structure({name="DlSubframeShareReservation", fieldName=fieldName, position=position, size=12}, {
            fields.uint8({name="minimumSubframeShare", position=0}),
            fields.uint8({name="maximumSubframeShare", position=1}),
            fields.Padding({name="maximumSubframeShare_extensions_padding", position=2, size=2}),
            xp_dss_DlSubframeShareReservationExtensions("extensions", 4),
        })
end

return DlSubframeShareReservation
