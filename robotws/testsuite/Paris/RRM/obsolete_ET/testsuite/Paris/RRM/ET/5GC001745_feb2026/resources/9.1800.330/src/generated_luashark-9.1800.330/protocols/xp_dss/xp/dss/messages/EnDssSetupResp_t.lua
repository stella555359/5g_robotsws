-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
