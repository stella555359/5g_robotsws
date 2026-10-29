-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_UlPrbShareReservationExtensions = require("xp/dss/UlPrbShareReservationExtensions")


-- A client can reserve a minimum amount of PRBs as well by giving a desired minimum share. It is up to the CRM to allocate the exact positions of the PRBs. In case the client has already reserved PRBs, those are included in the calculation of the minimum share and CRM just allocates that amount of additional PRBs needed to fulfill the minimum share.
--      The info elements contains as well the maximum share of PRBs that the client wants to use.
function UlPrbShareReservation (fieldName, position)
    return
        fields.Structure({name="UlPrbShareReservation", fieldName=fieldName, position=position, size=12}, {
            fields.uint8({name="minimumPrbShare", position=0}),
            fields.uint8({name="maximumPrbShare", position=1}),
            fields.Padding({name="maximumPrbShare_extension_padding", position=2, size=2}),
            xp_dss_UlPrbShareReservationExtensions("extension", 4),
        })
end

return UlPrbShareReservation
