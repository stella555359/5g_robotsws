-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_messages__ExtensionUnion_BbpDlPrbShareCalculationReqExtensions = require("xp/bbp/messages/_ExtensionUnion_BbpDlPrbShareCalculationReqExtensions"),
}

function BbpDlPrbShareCalculationReqExtensions (fieldName, position)
    return
        fields.ExtensionPoint({name="BbpDlPrbShareCalculationReqExtensions", fieldName=fieldName, position=position, size=8}, {
            fields.DynamicVariableSizedArray({name="_ExtensionArray", position=0, size=8, numSizePaddingBytes=0, numItems=0, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_bbp_messages__ExtensionUnion_BbpDlPrbShareCalculationReqExtensions("_ExtensionArray", 0)
            ),
        })
end

return BbpDlPrbShareCalculationReqExtensions
