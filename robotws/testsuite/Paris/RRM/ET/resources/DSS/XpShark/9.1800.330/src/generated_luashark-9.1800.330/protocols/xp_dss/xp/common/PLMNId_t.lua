-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")


function PLMNId_t (fieldName, position)
    return
        fields.Structure({name="PLMNId_t", fieldName=fieldName, position=position, size=4}, {
            fields.StaticFixedSizedArray({name="plmnOctets", position=0, size=4, numSizePaddingBytes=0, numItems=3, numPaddingBytes=1},
                fields.uint8({name="item", position=0})
            ),
        })
end

return PLMNId_t
