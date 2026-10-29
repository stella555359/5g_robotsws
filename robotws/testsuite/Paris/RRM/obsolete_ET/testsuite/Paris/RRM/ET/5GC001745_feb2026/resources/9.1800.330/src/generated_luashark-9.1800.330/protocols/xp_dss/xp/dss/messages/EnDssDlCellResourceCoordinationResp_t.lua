-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
