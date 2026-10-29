-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b
local fields = require("message")


function FixedSubframePattern (fieldName, position)
    return
        fields.BitSet({name="FixedSubframePattern", fieldName=fieldName, position=position, size=12, padding=2},
            fields.byte({name="byte", position=position}))
end

return FixedSubframePattern
