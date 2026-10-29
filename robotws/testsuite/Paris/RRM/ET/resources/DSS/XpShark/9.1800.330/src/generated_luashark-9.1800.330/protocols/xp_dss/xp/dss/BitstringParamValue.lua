-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6
local fields = require("message")


function BitstringParamValue (fieldName, position)
    return
        fields.BitSet({name="BitstringParamValue", fieldName=fieldName, position=position, size=32, padding=0},
            fields.byte({name="byte", position=position}))
end

return BitstringParamValue
