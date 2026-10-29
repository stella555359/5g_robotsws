-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_DlResourceSharingAlgo = require("xp/dss/DlResourceSharingAlgo"),
      xp_dss_EnDssDlCrmSfInfoExtension1Extensions = require("xp/dss/EnDssDlCrmSfInfoExtension1Extensions"),
}

function EnDssDlCrmSfInfoExtension1 (fieldName, position)
    return
        fields.Structure({name="EnDssDlCrmSfInfoExtension1", fieldName=fieldName, position=position, size=24}, {
            fields.StaticVariableSizedArray({name="superfastAllocationEnabled", position=0, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.boolean({name="item", position=0})
            ),
            fields.StaticVariableSizedArray({name="dlResourceSharingAlgo", position=8, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=8, enumTerm=localVarTable.xp_dss_DlResourceSharingAlgo},
                    ProtoField.int32, 4, "int32")
            ),
            localVarTable.xp_dss_EnDssDlCrmSfInfoExtension1Extensions("extensions", 16),
        })
end

return EnDssDlCrmSfInfoExtension1
