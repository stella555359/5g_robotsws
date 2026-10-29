-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
