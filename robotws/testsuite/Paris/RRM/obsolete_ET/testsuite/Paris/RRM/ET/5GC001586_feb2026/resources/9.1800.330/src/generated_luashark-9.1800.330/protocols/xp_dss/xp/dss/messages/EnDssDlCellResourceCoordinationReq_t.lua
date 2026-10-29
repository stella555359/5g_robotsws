-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_common_XpAddress_t = require("xp/common/XpAddress_t")
local xp_dss_EnDssAllowedMbsfnSubframes = require("xp/dss/EnDssAllowedMbsfnSubframes")
local xp_dss_FddCellFrequencyInfo = require("xp/dss/FddCellFrequencyInfo")
local xp_dss_EnDssDlCrmInfo = require("xp/dss/EnDssDlCrmInfo")
local xp_dss_messages_EnDssDlCellResourceCoordinationReqExtensions = require("xp/dss/messages/EnDssDlCellResourceCoordinationReqExtensions")


-- This message is sent by an initiating CRM Client to a CRM.
--      EN DSS DL CELL RESOURCE COORDINATION REQUEST uses EN DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The initiating CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM in the header.
--      Additionally, the client transfers the NEID and the EPID of the partner cell, with which it would like to perform DSS, in the payload.
--      All mandatory parameters of the message need to be sent by both clients. The optional parameters need to be sent by at least one client. In 19B this is the LTE client.
function EnDssDlCellResourceCoordinationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellResourceCoordinationReq_t", fieldName=fieldName, position=position, size=124}, {
            xp_common_XpAddress_t("candidateCellXpAddress", 0),
            xp_dss_EnDssAllowedMbsfnSubframes("enDssDlAllowedSubframes", 16),
            xp_dss_FddCellFrequencyInfo("fddCellFrequencyInfo", 24),
            xp_dss_EnDssDlCrmInfo("enDssDlCrmInfo", 32),
            xp_dss_messages_EnDssDlCellResourceCoordinationReqExtensions("extensions", 116),
        })
end

return EnDssDlCellResourceCoordinationReq_t
