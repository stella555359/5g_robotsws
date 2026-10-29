-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_Capabilities = require("xp/dss/Capabilities")
local xp_dss_EnDssPowerInfo = require("xp/dss/EnDssPowerInfo")
local xp_dss_EnDssDlCrmSfInfoExtension1_1Extensions = require("xp/dss/EnDssDlCrmSfInfoExtension1_1Extensions")


function EnDssDlCrmSfInfoExtension1_1 (fieldName, position)
    return
        fields.Structure({name="EnDssDlCrmSfInfoExtension1_1", fieldName=fieldName, position=position, size=92}, {
            fields.StaticVariableSizedArray({name="capabilities", position=0, size=36, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_Capabilities("capabilities", 0)
            ),
            fields.StaticVariableSizedArray({name="powerInfo", position=36, size=48, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_EnDssPowerInfo("powerInfo", 36)
            ),
            xp_dss_EnDssDlCrmSfInfoExtension1_1Extensions("extensions", 84),
        })
end

return EnDssDlCrmSfInfoExtension1_1
