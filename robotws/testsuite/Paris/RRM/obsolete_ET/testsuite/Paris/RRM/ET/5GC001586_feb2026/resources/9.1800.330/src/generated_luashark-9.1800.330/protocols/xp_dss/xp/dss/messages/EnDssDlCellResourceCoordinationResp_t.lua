-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_EnDssDlCrmClientInfo = require("xp/dss/EnDssDlCrmClientInfo")
local xp_dss_messages_EnDssDlCellResourceCoordinationRespExtensions = require("xp/dss/messages/EnDssDlCellResourceCoordinationRespExtensions")


-- Direction: CRM -> CRM client
--      This message is sent by the CRM to both CRM clients after it has received both requests from both clients.
--      EN DSS DL CELL RESOURCE COORDINATION RESPONSE uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssDlCellResourceCoordinationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellResourceCoordinationResp_t", fieldName=fieldName, position=position, size=12}, {
            xp_dss_EnDssDlCrmClientInfo("enDssDlCrmClientInfo", 0),
            xp_dss_messages_EnDssDlCellResourceCoordinationRespExtensions("extensions", 4),
        })
end

return EnDssDlCellResourceCoordinationResp_t
