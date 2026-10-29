-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_XpAddress_t = require("xp/common/XpAddress_t")
local xp_dss_FddCellUlPhyInfo = require("xp/dss/FddCellUlPhyInfo")
local xp_dss_EnDssUlCrmScInfo = require("xp/dss/EnDssUlCrmScInfo")
local xp_dss_UlPrbShareReservation = require("xp/dss/UlPrbShareReservation")
local xp_dss_PrbAreas = require("xp/dss/PrbAreas")
local xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationReqExtensions = require("xp/dss/messages/EnDssUlCellSubcarrierResourceCoordinationReqExtensions")


-- Direction: CRM Client -> CRM
--      This message is sent by an initiating CRM Client to a CRM.
-- 
--      EN DSS UL CELL SUBCARRIER RESOURCE COORDINATION REQUEST uses EN DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The initiating CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM in the header.
-- 
--      Additionally, the client transfers the NEID and the EPID of the partner cell, with which it would like to perform DSS, in the payload.
-- 
--      All mandatory parameters of the message need to be sent by both clients. The optional parameters need to be sent by at least one client.
function EnDssUlCellSubcarrierResourceCoordinationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssUlCellSubcarrierResourceCoordinationReq_t", fieldName=fieldName, position=position, size=288}, {
            xp_common_XpAddress_t("candidateCellXpAddress", 0),
            xp_dss_FddCellUlPhyInfo("fddCellUlPhyInfo", 16),
            fields.StaticVariableSizedArray({name="enDssUlCrmScInfo", position=32, size=124, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_EnDssUlCrmScInfo("enDssUlCrmScInfo", 32)
            ),
            xp_dss_UlPrbShareReservation("ulPrbShareReservation", 156),
            fields.StaticVariableSizedArray({name="ulPrbReservation", position=168, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreas("ulPrbReservation", 168)
            ),
            fields.StaticVariableSizedArray({name="ulPrbRelease", position=224, size=56, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbAreas("ulPrbRelease", 224)
            ),
            xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationReqExtensions("extensions", 280),
        })
end

return EnDssUlCellSubcarrierResourceCoordinationReq_t
