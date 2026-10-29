-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")


function MessageSet (fieldName, position)
    return
        fields.Structure({name="MessageSet", fieldName=fieldName, position=position, size=28}, {
            fields.StaticVariableSizedArray({name="data", position=0, size=28, numSizePaddingBytes=0, numItems=24, numPaddingBytes=0},
                fields.uint32, fields.uint8({name="item", position=0})
            ),
        })
end

return MessageSet
