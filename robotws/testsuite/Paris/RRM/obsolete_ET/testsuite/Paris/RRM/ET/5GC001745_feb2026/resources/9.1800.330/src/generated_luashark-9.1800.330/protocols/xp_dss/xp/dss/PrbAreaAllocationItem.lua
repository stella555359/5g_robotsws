-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_PrbRange = require("xp/dss/PrbRange")


function PrbAreaAllocationItem (fieldName, position)
    return
        fields.Structure({name="PrbAreaAllocationItem", fieldName=fieldName, position=position, size=12}, {
            fields.StaticVariableSizedArray({name="prbRangeList", position=0, size=12, numSizePaddingBytes=0, numItems=2, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbRange("prbRangeList", 0)
            ),
        })
end

return PrbAreaAllocationItem
