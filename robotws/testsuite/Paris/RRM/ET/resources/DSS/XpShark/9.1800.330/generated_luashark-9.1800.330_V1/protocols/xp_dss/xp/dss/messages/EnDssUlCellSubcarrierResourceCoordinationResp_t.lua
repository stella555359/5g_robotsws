-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssUlCrmScInfo = require("xp/dss/EnDssUlCrmScInfo"),
      xp_dss_EnDssUlReservationInfo = require("xp/dss/EnDssUlReservationInfo"),
      xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationRespExtensions = require("xp/dss/messages/EnDssUlCellSubcarrierResourceCoordinationRespExtensions"),
}

-- Direction: CRM -> CRM client
--      This message is sent by the CRM to both CRM clients after it has received both requests from both clients.
--      EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION RESPONSE uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssUlCellSubcarrierResourceCoordinationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssUlCellSubcarrierResourceCoordinationResp_t", fieldName=fieldName, position=position, size=352}, {
            localVarTable.xp_dss_EnDssUlCrmScInfo("enDssUlCrmScInfo", 0),
            localVarTable.xp_dss_EnDssUlReservationInfo("enDssUlReservationInfo", 120),
            localVarTable.xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationRespExtensions("extensions", 344),
        })
end

return EnDssUlCellSubcarrierResourceCoordinationResp_t
