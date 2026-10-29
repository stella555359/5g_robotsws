-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlCrmClientInfo = require("xp/dss/EnDssDlCrmClientInfo"),
      xp_dss_messages_EnDssDlCellResourceCoordinationRespExtensions = require("xp/dss/messages/EnDssDlCellResourceCoordinationRespExtensions"),
}

-- Direction: CRM -> CRM client
--      This message is sent by the CRM to both CRM clients after it has received both requests from both clients.
--      EN DSS DL CELL RESOURCE COORDINATION RESPONSE uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssDlCellResourceCoordinationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellResourceCoordinationResp_t", fieldName=fieldName, position=position, size=12}, {
            localVarTable.xp_dss_EnDssDlCrmClientInfo("enDssDlCrmClientInfo", 0),
            localVarTable.xp_dss_messages_EnDssDlCellResourceCoordinationRespExtensions("extensions", 4),
        })
end

return EnDssDlCellResourceCoordinationResp_t
