-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_PrbAreaAllocationItem = require("xp/dss/PrbAreaAllocationItem")


function PrbAreaAllocationList (fieldName, position)
    return
        fields.Structure({name="PrbAreaAllocationList", fieldName=fieldName, position=position, size=964}, {
            fields.StaticVariableSizedArray({name="items", position=0, size=964, numSizePaddingBytes=0, numItems=80, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreaAllocationItem("items", 0)
            ),
        })
end

return PrbAreaAllocationList
