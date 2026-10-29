-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")


function _ExtensionUnion_BbpPdschLayerShareCalculationRespExtensions (fieldName, position)
    return
        fields.DynamicUnion({name="_ExtensionUnion_BbpPdschLayerShareCalculationRespExtensions", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            },
            {0}
        )
end

return _ExtensionUnion_BbpPdschLayerShareCalculationRespExtensions
