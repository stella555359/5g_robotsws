-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
