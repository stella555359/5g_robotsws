-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b
local fields = require("message")


function BitstringParamValue (fieldName, position)
    return
        fields.BitSet({name="BitstringParamValue", fieldName=fieldName, position=position, size=32, padding=0},
            fields.byte({name="byte", position=position}))
end

return BitstringParamValue
