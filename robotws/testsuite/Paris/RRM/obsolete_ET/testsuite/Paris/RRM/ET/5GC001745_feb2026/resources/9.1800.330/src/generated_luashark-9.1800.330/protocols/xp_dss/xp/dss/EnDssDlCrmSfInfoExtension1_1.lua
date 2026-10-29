-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
