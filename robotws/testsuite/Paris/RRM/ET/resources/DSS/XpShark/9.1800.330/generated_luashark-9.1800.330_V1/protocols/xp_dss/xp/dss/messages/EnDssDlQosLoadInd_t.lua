-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlQosLoadMeasurement = require("xp/dss/EnDssDlQosLoadMeasurement"),
      xp_dss_messages_EnDssDlQosLoadIndExtensions = require("xp/dss/messages/EnDssDlQosLoadIndExtensions"),
}

-- Direction: CRM Client -> CRM.
--     This message is sent by a CRM Client to deliver the measured load to the CRM.
--     EN DSS DL LOAD INDICATION uses EN_DSS_DL_UNREL_TRS as Protocol ID.
function EnDssDlQosLoadInd_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlQosLoadInd_t", fieldName=fieldName, position=position, size=52}, {
            fields.uint32({name="allocationSequenceNumber", position=0}),
            localVarTable.xp_dss_EnDssDlQosLoadMeasurement("dssDlQosLoadMeasurement", 4),
            localVarTable.xp_dss_messages_EnDssDlQosLoadIndExtensions("extensions", 44),
        })
end

return EnDssDlQosLoadInd_t
