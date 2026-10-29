-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_PrbAreaAllocationItem = require("xp/dss/PrbAreaAllocationItem")


function PrbAreaAllocationList (fieldName, position)
    return
        fields.Structure({name="PrbAreaAllocationList", fieldName=fieldName, position=position, size=964}, {
            fields.StaticVariableSizedArray({name="items", position=0, size=964, numSizePaddingBytes=0, numItems=80, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreaAllocationItem("items", 0)
            ),
        })
end

return PrbAreaAllocationList
