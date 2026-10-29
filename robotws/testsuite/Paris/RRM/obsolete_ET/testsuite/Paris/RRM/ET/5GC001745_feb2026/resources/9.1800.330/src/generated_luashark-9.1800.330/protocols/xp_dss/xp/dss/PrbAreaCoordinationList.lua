-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_PrbAreaCoordinationItem = require("xp/dss/PrbAreaCoordinationItem")


function PrbAreaCoordinationList (fieldName, position)
    return
        fields.Structure({name="PrbAreaCoordinationList", fieldName=fieldName, position=position, size=8}, {
            fields.DynamicVariableSizedArray({name="items", position=0, size=8, numSizePaddingBytes=0, numItems=80, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_dss_PrbAreaCoordinationItem("items", 0)
            ),
        })
end

return PrbAreaCoordinationList
