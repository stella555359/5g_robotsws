-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
