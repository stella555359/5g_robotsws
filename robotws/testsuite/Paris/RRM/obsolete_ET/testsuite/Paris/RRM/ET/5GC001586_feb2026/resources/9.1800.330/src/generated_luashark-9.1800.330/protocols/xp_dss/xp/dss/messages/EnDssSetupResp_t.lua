-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_MessageSet = require("xp/dss/MessageSet")
local xp_dss_messages_EnDssSetupRespExtensions = require("xp/dss/messages/EnDssSetupRespExtensions")


-- Direction: CRM -> CRM client
--      This message is sent by the CRM in case of success after it has received both EN DSS setup requests of the CRM Clients.
--      EN DSS SETUP RESPONSE uses EN DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
--      The response includes as well the highest ranked common message set being supported.
function EnDssSetupResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssSetupResp_t", fieldName=fieldName, position=position, size=36}, {
            xp_dss_MessageSet("enDssMessageSet", 0),
            xp_dss_messages_EnDssSetupRespExtensions("extensions", 28),
        })
end

return EnDssSetupResp_t
