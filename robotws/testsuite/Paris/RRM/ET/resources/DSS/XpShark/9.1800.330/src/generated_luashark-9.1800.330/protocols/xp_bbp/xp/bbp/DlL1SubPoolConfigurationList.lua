-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_DlL1SubPoolConfigurationItem = require("xp/bbp/DlL1SubPoolConfigurationItem")
local xp_bbp_DlL1SubPoolConfigurationListExtensions = require("xp/bbp/DlL1SubPoolConfigurationListExtensions")


function DlL1SubPoolConfigurationList (fieldName, position)
    return
        fields.Structure({name="DlL1SubPoolConfigurationList", fieldName=fieldName, position=position, size=16}, {
            fields.DynamicVariableSizedArray({name="items", position=0, size=8, numSizePaddingBytes=0, numItems=8, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_bbp_DlL1SubPoolConfigurationItem("items", 0)
            ),
            xp_bbp_DlL1SubPoolConfigurationListExtensions("extensions", 8),
        })
end

return DlL1SubPoolConfigurationList
