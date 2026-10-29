-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_EnDssDlQosLoadMeasurement = require("xp/dss/EnDssDlQosLoadMeasurement")
local xp_dss_messages_EnDssDlQosLoadIndExtensions = require("xp/dss/messages/EnDssDlQosLoadIndExtensions")


-- Direction: CRM Client -> CRM.
--     This message is sent by a CRM Client to deliver the measured load to the CRM.
--     EN DSS DL LOAD INDICATION uses EN_DSS_DL_UNREL_TRS as Protocol ID.
function EnDssDlQosLoadInd_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlQosLoadInd_t", fieldName=fieldName, position=position, size=52}, {
            fields.uint32({name="allocationSequenceNumber", position=0}),
            xp_dss_EnDssDlQosLoadMeasurement("dssDlQosLoadMeasurement", 4),
            xp_dss_messages_EnDssDlQosLoadIndExtensions("extensions", 44),
        })
end

return EnDssDlQosLoadInd_t
