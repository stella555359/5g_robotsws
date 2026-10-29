-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlCrmSfInfo = require("xp/dss/EnDssDlCrmSfInfo"),
      xp_dss_DlPrbReservationInfo = require("xp/dss/DlPrbReservationInfo"),
      xp_dss_messages_EnDssDlCellResourceAreaCoordinationRespExtensions = require("xp/dss/messages/EnDssDlCellResourceAreaCoordinationRespExtensions"),
}

-- Direction: CRM -> CRM client
--      This message is sent by the CRM to the CRM client which sent the EN DSS DL CELL RESOURCE AREA COORDINATION REQUEST.
--      EN DSS DL CELL RESOURCE AREA COORDINATION RESPONSE uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssDlCellResourceAreaCoordinationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellResourceAreaCoordinationResp_t", fieldName=fieldName, position=position, size=220}, {
            localVarTable.xp_dss_EnDssDlCrmSfInfo("enDssDlCrmSfInfo", 0),
            localVarTable.xp_dss_DlPrbReservationInfo("enDssDlPrbReservationInfo", 132),
            localVarTable.xp_dss_messages_EnDssDlCellResourceAreaCoordinationRespExtensions("extensions", 212),
        })
end

return EnDssDlCellResourceAreaCoordinationResp_t
