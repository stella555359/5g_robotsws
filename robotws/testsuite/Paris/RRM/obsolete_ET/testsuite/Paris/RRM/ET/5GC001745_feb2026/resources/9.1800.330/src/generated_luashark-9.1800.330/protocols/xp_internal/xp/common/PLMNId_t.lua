-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
