-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")


function _ExtensionUnion_EnDssDlResourceAllocationFailExtensions (fieldName, position)
    return
        fields.DynamicUnion({name="_ExtensionUnion_EnDssDlResourceAllocationFailExtensions", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            },
            {0}
        )
end

return _ExtensionUnion_EnDssDlResourceAllocationFailExtensions
