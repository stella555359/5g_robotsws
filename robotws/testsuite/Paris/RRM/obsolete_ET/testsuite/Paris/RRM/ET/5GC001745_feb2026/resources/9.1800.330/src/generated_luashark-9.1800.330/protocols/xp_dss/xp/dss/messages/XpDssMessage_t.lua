-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_messages_EnDssErrorInd_t = require("xp/dss/messages/EnDssErrorInd_t")
local xp_dss_messages_EnDssSetupReq_t = require("xp/dss/messages/EnDssSetupReq_t")
local xp_dss_messages_EnDssSetupResp_t = require("xp/dss/messages/EnDssSetupResp_t")
local xp_dss_messages_EnDssSetupFail_t = require("xp/dss/messages/EnDssSetupFail_t")
local xp_dss_messages_EnDssKeepAlive_t = require("xp/dss/messages/EnDssKeepAlive_t")
local xp_dss_messages_EnDssDlCellResourceCoordinationReq_t = require("xp/dss/messages/EnDssDlCellResourceCoordinationReq_t")
local xp_dss_messages_EnDssDlCellResourceCoordinationResp_t = require("xp/dss/messages/EnDssDlCellResourceCoordinationResp_t")
local xp_dss_messages_EnDssDlCellResourceCoordinationFail_t = require("xp/dss/messages/EnDssDlCellResourceCoordinationFail_t")
local xp_dss_messages_EnDssDlResourceAllocationReq_t = require("xp/dss/messages/EnDssDlResourceAllocationReq_t")
local xp_dss_messages_EnDssDlResourceAllocationResp_t = require("xp/dss/messages/EnDssDlResourceAllocationResp_t")
local xp_dss_messages_EnDssDlResourceAllocationFail_t = require("xp/dss/messages/EnDssDlResourceAllocationFail_t")
local xp_dss_messages_EnDssDlLoadInd_t = require("xp/dss/messages/EnDssDlLoadInd_t")
local xp_dss_messages_EnDssRemoval_t = require("xp/dss/messages/EnDssRemoval_t")
local xp_dss_messages_EnDssDlCellSubframeResourceCoordinationReq_t = require("xp/dss/messages/EnDssDlCellSubframeResourceCoordinationReq_t")
local xp_dss_messages_EnDssDlCellSubframeResourceCoordinationResp_t = require("xp/dss/messages/EnDssDlCellSubframeResourceCoordinationResp_t")
local xp_dss_messages_EnDssDlCellSubframeResourceCoordinationFail_t = require("xp/dss/messages/EnDssDlCellSubframeResourceCoordinationFail_t")
local xp_dss_messages_EnDssDlSubframeResourceAllocationReq_t = require("xp/dss/messages/EnDssDlSubframeResourceAllocationReq_t")
local xp_dss_messages_EnDssDlSubframeResourceAllocationResp_t = require("xp/dss/messages/EnDssDlSubframeResourceAllocationResp_t")
local xp_dss_messages_EnDssDlSubframeResourceAllocationFail_t = require("xp/dss/messages/EnDssDlSubframeResourceAllocationFail_t")
local xp_dss_messages_EnDssDlQosLoadInd_t = require("xp/dss/messages/EnDssDlQosLoadInd_t")
local xp_dss_messages_EnDssAperiodicDlAllocationReq_t = require("xp/dss/messages/EnDssAperiodicDlAllocationReq_t")
local xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationReq_t = require("xp/dss/messages/EnDssUlCellSubcarrierResourceCoordinationReq_t")
local xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationResp_t = require("xp/dss/messages/EnDssUlCellSubcarrierResourceCoordinationResp_t")
local xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationFail_t = require("xp/dss/messages/EnDssUlCellSubcarrierResourceCoordinationFail_t")
local xp_dss_messages_EnDssUlSubcarrierResourceAllocationReq_t = require("xp/dss/messages/EnDssUlSubcarrierResourceAllocationReq_t")
local xp_dss_messages_EnDssUlSubcarrierResourceAllocationResp_t = require("xp/dss/messages/EnDssUlSubcarrierResourceAllocationResp_t")
local xp_dss_messages_EnDssUlSubcarrierResourceAllocationFail_t = require("xp/dss/messages/EnDssUlSubcarrierResourceAllocationFail_t")
local xp_dss_messages_EnDssUlQosLoadInd_t = require("xp/dss/messages/EnDssUlQosLoadInd_t")
local xp_dss_messages_EnDssDlCellResourceAreaCoordinationReq_t = require("xp/dss/messages/EnDssDlCellResourceAreaCoordinationReq_t")
local xp_dss_messages_EnDssDlCellResourceAreaCoordinationResp_t = require("xp/dss/messages/EnDssDlCellResourceAreaCoordinationResp_t")
local xp_dss_messages_EnDssDlCellResourceAreaCoordinationFail_t = require("xp/dss/messages/EnDssDlCellResourceAreaCoordinationFail_t")
local xp_dss_messages_EnDssDlCellResourceAreaAllocationReq_t = require("xp/dss/messages/EnDssDlCellResourceAreaAllocationReq_t")
local xp_dss_messages_EnDssDlCellResourceAreaAllocationResp_t = require("xp/dss/messages/EnDssDlCellResourceAreaAllocationResp_t")
local xp_dss_messages_EnDssDlCellResourceAreaAllocationFail_t = require("xp/dss/messages/EnDssDlCellResourceAreaAllocationFail_t")


function XpDssMessage_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpDssMessage_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_dss_messages_EnDssErrorInd_t("enDssErrorInd", 0),
            xp_dss_messages_EnDssSetupReq_t("enDssSetupReq", 0),
            xp_dss_messages_EnDssSetupResp_t("enDssSetupResp", 0),
            xp_dss_messages_EnDssSetupFail_t("enDssSetupFail", 0),
            xp_dss_messages_EnDssSetupFail_t("enDssSetupFailInfo", 0),
            xp_dss_messages_EnDssKeepAlive_t("enDssKeepAliveReq", 0),
            xp_dss_messages_EnDssKeepAlive_t("enDssKeepAliveResp", 0),
            xp_dss_messages_EnDssDlCellResourceCoordinationReq_t("enDssDlCellResourceCoordinationReq", 0),
            xp_dss_messages_EnDssDlCellResourceCoordinationResp_t("enDssDlCellResourceCoordinationResp", 0),
            xp_dss_messages_EnDssDlCellResourceCoordinationFail_t("enDssDlCellResourceCoordinationFail", 0),
            xp_dss_messages_EnDssDlCellResourceCoordinationFail_t("enDssDlCellResourceCoordinationFailInfo", 0),
            xp_dss_messages_EnDssDlResourceAllocationReq_t("enDssDlResourceAllocationReq", 0),
            xp_dss_messages_EnDssDlResourceAllocationResp_t("enDssDlResourceAllocationResp", 0),
            xp_dss_messages_EnDssDlResourceAllocationFail_t("enDssDlResourceAllocationFail", 0),
            xp_dss_messages_EnDssDlLoadInd_t("enDssDlLoadInd", 0),
            xp_dss_messages_EnDssRemoval_t("enDssRemovalReq", 0),
            xp_dss_messages_EnDssRemoval_t("enDssRemovalResp", 0),
            xp_dss_messages_EnDssRemoval_t("enDssRemovalInfo", 0),
            xp_dss_messages_EnDssRemoval_t("enDssRemovalInfoResp", 0),
            xp_dss_messages_EnDssDlCellSubframeResourceCoordinationReq_t("enDssDlCellSubframeResourceCoordinationReq", 0),
            xp_dss_messages_EnDssDlCellSubframeResourceCoordinationResp_t("enDssDlCellSubframeResourceCoordinationResp", 0),
            xp_dss_messages_EnDssDlCellSubframeResourceCoordinationResp_t("enDssDlCellSubframeResourceCoordinationUpdateInd", 0),
            xp_dss_messages_EnDssDlCellSubframeResourceCoordinationFail_t("enDssDlCellSubframeResourceCoordinationFail", 0),
            xp_dss_messages_EnDssDlCellSubframeResourceCoordinationFail_t("enDssDlCellSubframeResourceCoordinationFailInfo", 0),
            xp_dss_messages_EnDssDlSubframeResourceAllocationReq_t("enDssDlSubframeResourceAllocationReq", 0),
            xp_dss_messages_EnDssDlSubframeResourceAllocationResp_t("enDssDlSubframeResourceAllocationResp", 0),
            xp_dss_messages_EnDssDlSubframeResourceAllocationFail_t("enDssDlSubframeResourceAllocationFail", 0),
            xp_dss_messages_EnDssDlQosLoadInd_t("enDssDlQosLoadInd", 0),
            xp_dss_messages_EnDssAperiodicDlAllocationReq_t("enDssAperiodicDlAllocationReq", 0),
            xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationReq_t("enDssUlCellSubcarrierResourceCoordinationReq", 0),
            xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationResp_t("enDssUlCellSubcarrierResourceCoordinationResp", 0),
            xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationResp_t("enDssUlCellSubcarrierResourceCoordinationUpdateInd", 0),
            xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationFail_t("enDssUlCellSubcarrierResourceCoordinationFail", 0),
            xp_dss_messages_EnDssUlCellSubcarrierResourceCoordinationFail_t("enDssUlCellSubcarrierResourceCoordinationFailInfo", 0),
            xp_dss_messages_EnDssUlSubcarrierResourceAllocationReq_t("enDssUlSubcarrierResourceAllocationReq", 0),
            xp_dss_messages_EnDssUlSubcarrierResourceAllocationResp_t("enDssUlSubcarrierResourceAllocationResp", 0),
            xp_dss_messages_EnDssUlSubcarrierResourceAllocationFail_t("enDssUlSubcarrierResourceAllocationFail", 0),
            xp_dss_messages_EnDssUlQosLoadInd_t("enDssUlQosLoadInd", 0),
            xp_dss_messages_EnDssDlCellResourceAreaCoordinationReq_t("enDssDlCellResourceAreaCoordinationReq", 0),
            xp_dss_messages_EnDssDlCellResourceAreaCoordinationResp_t("enDssDlCellResourceAreaCoordinationResp", 0),
            xp_dss_messages_EnDssDlCellResourceAreaCoordinationResp_t("enDssDlCellResourceAreaCoordinationUpdateInd", 0),
            xp_dss_messages_EnDssDlCellResourceAreaCoordinationFail_t("enDssDlCellResourceAreaCoordinationFail", 0),
            xp_dss_messages_EnDssDlCellResourceAreaCoordinationFail_t("enDssDlCellResourceAreaCoordinationFailInfo", 0),
            xp_dss_messages_EnDssDlCellResourceAreaAllocationReq_t("enDssDlCellResourceAreaAllocationReq", 0),
            xp_dss_messages_EnDssDlCellResourceAreaAllocationResp_t("enDssDlCellResourceAreaAllocationResp", 0),
            xp_dss_messages_EnDssDlCellResourceAreaAllocationFail_t("enDssDlCellResourceAreaAllocationFail", 0),
            },
            {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46}
        )
end

return XpDssMessage_t
