-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp__ExtensionUnion_DlL1SubPoolConfigurationItemExtensions = require("xp/bbp/_ExtensionUnion_DlL1SubPoolConfigurationItemExtensions")


function DlL1SubPoolConfigurationItemExtensions (fieldName, position)
    return
        fields.ExtensionPoint({name="DlL1SubPoolConfigurationItemExtensions", fieldName=fieldName, position=position, size=8}, {
            fields.DynamicVariableSizedArray({name="_ExtensionArray", position=0, size=8, numSizePaddingBytes=0, numItems=0, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_bbp__ExtensionUnion_DlL1SubPoolConfigurationItemExtensions("_ExtensionArray", 0)
            ),
        })
end

return DlL1SubPoolConfigurationItemExtensions
