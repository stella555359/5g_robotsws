-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
