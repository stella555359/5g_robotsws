-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss__ExtensionUnion_UlScAllocationInfoExtensions = require("xp/dss/_ExtensionUnion_UlScAllocationInfoExtensions"),
}

function UlScAllocationInfoExtensions (fieldName, position)
    return
        fields.ExtensionPoint({name="UlScAllocationInfoExtensions", fieldName=fieldName, position=position, size=8}, {
            fields.DynamicVariableSizedArray({name="_ExtensionArray", position=0, size=8, numSizePaddingBytes=0, numItems=0, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_dss__ExtensionUnion_UlScAllocationInfoExtensions("_ExtensionArray", 0)
            ),
        })
end

return UlScAllocationInfoExtensions
