-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_FailureDescription = require("xp/dss/FailureDescription")


function NumberParameterValues (fieldName, position)
    return
        fields.Structure({name="NumberParameterValues", fieldName=fieldName, position=position, size=272}, {
            xp_dss_FailureDescription("name", 0),
            fields.StaticVariableSizedArray({name="valueLte", position=256, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.int32({name="item", position=256})
            ),
            fields.StaticVariableSizedArray({name="valueNr", position=264, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.int32({name="item", position=264})
            ),
        })
end

return NumberParameterValues
