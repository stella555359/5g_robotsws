-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_EnDssUlCrmScInfo = require("xp/dss/EnDssUlCrmScInfo")
local xp_dss_EnDssUlReservationInfo = require("xp/dss/EnDssUlReservationInfo")
local xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationRespExtensions = require("xp/dss/messages/EnDssUlCellSubcarrierResourceCoordinationRespExtensions")


-- Direction: CRM -> CRM client
--      This message is sent by the CRM to both CRM clients after it has received both requests from both clients.
--      EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION RESPONSE uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssUlCellSubcarrierResourceCoordinationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssUlCellSubcarrierResourceCoordinationResp_t", fieldName=fieldName, position=position, size=352}, {
            xp_dss_EnDssUlCrmScInfo("enDssUlCrmScInfo", 0),
            xp_dss_EnDssUlReservationInfo("enDssUlReservationInfo", 120),
            xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationRespExtensions("extensions", 344),
        })
end

return EnDssUlCellSubcarrierResourceCoordinationResp_t
