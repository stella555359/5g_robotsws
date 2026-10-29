-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
