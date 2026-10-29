-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")


function InternalAddress_t (fieldName, position)
    return
        fields.StaticUnion({name="InternalAddress_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32,
            {
            fields.uint32({name="sicad", position=0}),
            fields.uint32({name="eqid", position=0}),
            }
        )
end

return InternalAddress_t
