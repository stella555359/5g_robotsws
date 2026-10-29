-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
