-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlCrmSfInfoExtension1_1 = require("xp/dss/EnDssDlCrmSfInfoExtension1_1"),
}

function _ExtensionUnion_EnDssDlCrmSfInfoExtension1Extensions (fieldName, position)
    return
        fields.DynamicUnion({name="_ExtensionUnion_EnDssDlCrmSfInfoExtension1Extensions", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            localVarTable.xp_dss_EnDssDlCrmSfInfoExtension1_1("extensionPoint1_1", 0),
            },
            {0, 1}
        )
end

return _ExtensionUnion_EnDssDlCrmSfInfoExtension1Extensions
