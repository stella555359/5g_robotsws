-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss__ExtensionUnion_DlSubframeReservationExtensions = require("xp/dss/_ExtensionUnion_DlSubframeReservationExtensions")


function DlSubframeReservationExtensions (fieldName, position)
    return
        fields.ExtensionPoint({name="DlSubframeReservationExtensions", fieldName=fieldName, position=position, size=8}, {
            fields.DynamicVariableSizedArray({name="_ExtensionArray", position=0, size=8, numSizePaddingBytes=0, numItems=0, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_dss__ExtensionUnion_DlSubframeReservationExtensions("_ExtensionArray", 0)
            ),
        })
end

return DlSubframeReservationExtensions
