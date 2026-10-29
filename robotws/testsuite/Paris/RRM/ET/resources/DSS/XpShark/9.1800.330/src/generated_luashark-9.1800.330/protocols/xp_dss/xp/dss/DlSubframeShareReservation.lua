-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
