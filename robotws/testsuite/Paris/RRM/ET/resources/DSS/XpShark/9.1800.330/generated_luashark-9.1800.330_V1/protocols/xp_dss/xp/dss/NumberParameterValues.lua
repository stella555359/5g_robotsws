-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_FailureDescription = require("xp/dss/FailureDescription"),
}

function NumberParameterValues (fieldName, position)
    return
        fields.Structure({name="NumberParameterValues", fieldName=fieldName, position=position, size=272}, {
            localVarTable.xp_dss_FailureDescription("name", 0),
            fields.StaticVariableSizedArray({name="valueLte", position=256, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.int32({name="item", position=256})
            ),
            fields.StaticVariableSizedArray({name="valueNr", position=264, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.int32({name="item", position=264})
            ),
        })
end

return NumberParameterValues
