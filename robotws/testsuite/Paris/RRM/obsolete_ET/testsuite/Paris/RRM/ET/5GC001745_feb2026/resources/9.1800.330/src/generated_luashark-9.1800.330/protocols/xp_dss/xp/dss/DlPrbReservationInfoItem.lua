-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_FixedSubframePattern = require("xp/dss/FixedSubframePattern")
local xp_dss_PrbAreaCoordinationList = require("xp/dss/PrbAreaCoordinationList")


function DlPrbReservationInfoItem (fieldName, position)
    return
        fields.Structure({name="DlPrbReservationInfoItem", fieldName=fieldName, position=position, size=36}, {
            xp_dss_FixedSubframePattern("reservedMbsfnSubframes", 0),
            fields.StaticVariableSizedArray({name="reservedPrbAreaCoordinationList", position=12, size=12, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreaCoordinationList("reservedPrbAreaCoordinationList", 12)
            ),
            fields.StaticVariableSizedArray({name="releasedPrbAreaCoordinationList", position=24, size=12, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreaCoordinationList("releasedPrbAreaCoordinationList", 24)
            ),
        })
end

return DlPrbReservationInfoItem
