-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_common_XpAddress_t = require("xp/common/XpAddress_t")
local xp_dss_FddCellDlPhyInfo = require("xp/dss/FddCellDlPhyInfo")
local xp_dss_EnDssDlCrmSfInfo = require("xp/dss/EnDssDlCrmSfInfo")
local xp_dss_DlSubframeReservation = require("xp/dss/DlSubframeReservation")
local xp_dss_DlSubframeShareReservation = require("xp/dss/DlSubframeShareReservation")
local xp_dss_PrbAreas = require("xp/dss/PrbAreas")
local xp_dss_messages_EnDssDlCellSubframeResourceCoordinationReqExtensions = require("xp/dss/messages/EnDssDlCellSubframeResourceCoordinationReqExtensions")


-- Direction: CRM Client -> CRM
--     This message is sent by an initiating CRM Client to a CRM.
--     EN DSS DL CELL SUBFRAME RESOURCE COORDINATION REQUEST uses EN DSS_REL_TRS as Protocol ID.
--     The initiating CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM in the header.
--     Additionally, the client transfers the NEID and the EPID of the partner cell, with which it would like to perform DSS, in the payload.
--     All mandatory parameters of the message need to be sent by both clients. The optional parameters need to be sent by at least one client.
function EnDssDlCellSubframeResourceCoordinationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellSubframeResourceCoordinationReq_t", fieldName=fieldName, position=position, size=424}, {
            xp_common_XpAddress_t("candidateCellXpAddress", 0),
            xp_dss_FddCellDlPhyInfo("fddCellDlPhyInfo", 16),
            xp_dss_EnDssDlCrmSfInfo("enDssDlCrmSfInfo", 40),
            xp_dss_DlSubframeReservation("dlSubframeReservation", 172),
            xp_dss_DlSubframeShareReservation("dlSubframeShareReservation", 292),
            fields.StaticVariableSizedArray({name="dlPrbReservation", position=304, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreas("dlPrbReservation", 304)
            ),
            fields.StaticVariableSizedArray({name="dlPrbBlanking", position=360, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreas("dlPrbBlanking", 360)
            ),
            xp_dss_messages_EnDssDlCellSubframeResourceCoordinationReqExtensions("extensions", 416),
        })
end

return EnDssDlCellSubframeResourceCoordinationReq_t
