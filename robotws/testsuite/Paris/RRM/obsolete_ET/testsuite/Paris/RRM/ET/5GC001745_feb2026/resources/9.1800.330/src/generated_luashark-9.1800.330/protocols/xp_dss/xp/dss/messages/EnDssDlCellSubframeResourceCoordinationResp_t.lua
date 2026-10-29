-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EnDssDlCrmSfInfo = require("xp/dss/EnDssDlCrmSfInfo")
local xp_dss_EnDssDlReservationInfo = require("xp/dss/EnDssDlReservationInfo")
local xp_dss_messages_EnDssDlCellSubframeResourceCoordinationRespExtensions = require("xp/dss/messages/EnDssDlCellSubframeResourceCoordinationRespExtensions")


-- Direction: CRM -> CRM client
--     This message is sent by the CRM to both CRM clients after it has received both requests from both clients.
--     EN DSS DL CELL SUBFRAME RESOURCE COORDINATION RESPONSE uses EN_DSS_REL_TRS as Protocol ID.
function EnDssDlCellSubframeResourceCoordinationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellSubframeResourceCoordinationResp_t", fieldName=fieldName, position=position, size=420}, {
            xp_dss_EnDssDlCrmSfInfo("enDssDlCrmSfInfo", 0),
            xp_dss_EnDssDlReservationInfo("enDssDlReservationInfo", 132),
            xp_dss_messages_EnDssDlCellSubframeResourceCoordinationRespExtensions("extensions", 412),
        })
end

return EnDssDlCellSubframeResourceCoordinationResp_t
