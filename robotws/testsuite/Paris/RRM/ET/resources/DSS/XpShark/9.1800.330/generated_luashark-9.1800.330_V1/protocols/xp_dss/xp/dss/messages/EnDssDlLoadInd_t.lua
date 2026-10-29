-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlLoadMeasurements = require("xp/dss/EnDssDlLoadMeasurements"),
      xp_dss_messages_EnDssDlLoadIndExtensions = require("xp/dss/messages/EnDssDlLoadIndExtensions"),
}

-- Direction: CRM Client -> CRM.
--      This message is sent by a CRM Client to deliver the measured load to the CRM.
--      EN DSS DL LOAD INDICATION uses EN_DSS_DL_UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
function EnDssDlLoadInd_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlLoadInd_t", fieldName=fieldName, position=position, size=16}, {
            fields.uint32({name="allocationSequenceNumber", position=0}),
            localVarTable.xp_dss_EnDssDlLoadMeasurements("enDssDlLoadMeasurement", 4),
            localVarTable.xp_dss_messages_EnDssDlLoadIndExtensions("extensions", 8),
        })
end

return EnDssDlLoadInd_t
