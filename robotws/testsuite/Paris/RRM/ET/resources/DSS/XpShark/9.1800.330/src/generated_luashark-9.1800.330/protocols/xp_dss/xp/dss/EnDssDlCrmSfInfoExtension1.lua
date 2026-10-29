-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_DlResourceSharingAlgo = require("xp/dss/DlResourceSharingAlgo")
local xp_dss_EnDssDlCrmSfInfoExtension1Extensions = require("xp/dss/EnDssDlCrmSfInfoExtension1Extensions")


function EnDssDlCrmSfInfoExtension1 (fieldName, position)
    return
        fields.Structure({name="EnDssDlCrmSfInfoExtension1", fieldName=fieldName, position=position, size=24}, {
            fields.StaticVariableSizedArray({name="superfastAllocationEnabled", position=0, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.boolean({name="item", position=0})
            ),
            fields.StaticVariableSizedArray({name="dlResourceSharingAlgo", position=8, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=8, enumTerm=xp_dss_DlResourceSharingAlgo},
                    ProtoField.int32, 4, "int32")
            ),
            xp_dss_EnDssDlCrmSfInfoExtension1Extensions("extensions", 16),
        })
end

return EnDssDlCrmSfInfoExtension1
