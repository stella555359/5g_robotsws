-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_L1SubPoolPdschLayerAssignment = require("xp/bbp/L1SubPoolPdschLayerAssignment")
local xp_bbp_L1SubPoolPdschLayerAssignmentListExtensions = require("xp/bbp/L1SubPoolPdschLayerAssignmentListExtensions")


function L1SubPoolPdschLayerAssignmentList (fieldName, position)
    return
        fields.Structure({name="L1SubPoolPdschLayerAssignmentList", fieldName=fieldName, position=position, size=16}, {
            fields.DynamicVariableSizedArray({name="items", position=0, size=8, numSizePaddingBytes=0, numItems=8, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_bbp_L1SubPoolPdschLayerAssignment("items", 0)
            ),
            xp_bbp_L1SubPoolPdschLayerAssignmentListExtensions("extensions", 8),
        })
end

return L1SubPoolPdschLayerAssignmentList
