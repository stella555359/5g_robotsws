-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")


function PeriodicNormalSubframes (fieldName, position)
    return
        fields.Structure({name="PeriodicNormalSubframes", fieldName=fieldName, position=position, size=84}, {
            fields.StaticVariableSizedArray({name="periodicity", position=0, size=84, numSizePaddingBytes=0, numItems=80, numPaddingBytes=0},
                fields.uint32, fields.uint8({name="item", position=0})
            ),
        })
end

return PeriodicNormalSubframes
