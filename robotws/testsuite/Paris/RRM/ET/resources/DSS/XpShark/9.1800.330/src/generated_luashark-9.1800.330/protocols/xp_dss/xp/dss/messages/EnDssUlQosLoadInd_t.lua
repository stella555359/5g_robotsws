-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_EnDssUlQosLoadMeasurement = require("xp/dss/EnDssUlQosLoadMeasurement")
local xp_dss_messages_EnDssUlQosLoadIndExtensions = require("xp/dss/messages/EnDssUlQosLoadIndExtensions")


-- Direction: CRM Client? CRM.
--      This message is sent by a CRM Client to deliver the measured load to the CRM.
--      EN DSS DL LOAD INDICATION uses EN_DSS_DL_UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
function EnDssUlQosLoadInd_t (fieldName, position)
    return
        fields.Structure({name="EnDssUlQosLoadInd_t", fieldName=fieldName, position=position, size=24}, {
            fields.uint32({name="allocationSequenceNumber", position=0}),
            xp_dss_EnDssUlQosLoadMeasurement("enDssUlQosLoadMeasurement", 4),
            xp_dss_messages_EnDssUlQosLoadIndExtensions("extensions", 16),
        })
end

return EnDssUlQosLoadInd_t
