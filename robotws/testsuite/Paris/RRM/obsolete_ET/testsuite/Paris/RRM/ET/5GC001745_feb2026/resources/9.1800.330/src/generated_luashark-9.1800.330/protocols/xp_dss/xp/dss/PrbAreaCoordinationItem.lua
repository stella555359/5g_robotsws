-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_Time = require("xp/dss/Time")
local xp_dss_PrbRange = require("xp/dss/PrbRange")


function PrbAreaCoordinationItem (fieldName, position)
    return
        fields.Structure({name="PrbAreaCoordinationItem", fieldName=fieldName, position=position, size=28}, {
            xp_dss_Time("patternStartTime", 0),
            fields.uint16({name="periodicity", position=16}),
            fields.Padding({name="periodicity_prbRangeList_padding", position=18, size=2}),
            fields.DynamicVariableSizedArray({name="prbRangeList", position=20, size=8, numSizePaddingBytes=0, numItems=2, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_dss_PrbRange("prbRangeList", 20)
            ),
        })
end

return PrbAreaCoordinationItem
