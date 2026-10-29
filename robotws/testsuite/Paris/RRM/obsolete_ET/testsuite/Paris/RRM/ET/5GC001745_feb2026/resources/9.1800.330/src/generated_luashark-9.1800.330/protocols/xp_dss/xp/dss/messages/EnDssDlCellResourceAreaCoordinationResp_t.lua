-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EnDssDlCrmSfInfo = require("xp/dss/EnDssDlCrmSfInfo")
local xp_dss_DlPrbReservationInfo = require("xp/dss/DlPrbReservationInfo")
local xp_dss_messages_EnDssDlCellResourceAreaCoordinationRespExtensions = require("xp/dss/messages/EnDssDlCellResourceAreaCoordinationRespExtensions")


-- Direction: CRM -> CRM client
--      This message is sent by the CRM to the CRM client which sent the EN DSS DL CELL RESOURCE AREA COORDINATION REQUEST.
--      EN DSS DL CELL RESOURCE AREA COORDINATION RESPONSE uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssDlCellResourceAreaCoordinationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellResourceAreaCoordinationResp_t", fieldName=fieldName, position=position, size=220}, {
            xp_dss_EnDssDlCrmSfInfo("enDssDlCrmSfInfo", 0),
            xp_dss_DlPrbReservationInfo("enDssDlPrbReservationInfo", 132),
            xp_dss_messages_EnDssDlCellResourceAreaCoordinationRespExtensions("extensions", 212),
        })
end

return EnDssDlCellResourceAreaCoordinationResp_t
