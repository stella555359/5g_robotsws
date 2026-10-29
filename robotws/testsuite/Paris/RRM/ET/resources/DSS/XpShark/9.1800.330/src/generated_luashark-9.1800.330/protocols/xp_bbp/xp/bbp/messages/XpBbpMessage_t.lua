-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_messages_BbPoolingConfiguredCapacityCalculationReq_t = require("xp/bbp/messages/BbPoolingConfiguredCapacityCalculationReq_t")
local xp_bbp_messages_BbPoolingConfiguredCapacityCalculationResp_t = require("xp/bbp/messages/BbPoolingConfiguredCapacityCalculationResp_t")
local xp_bbp_messages_BbpDlPrbShareCalculationReq_t = require("xp/bbp/messages/BbpDlPrbShareCalculationReq_t")
local xp_bbp_messages_BbpDlPrbShareCalculationResp_t = require("xp/bbp/messages/BbpDlPrbShareCalculationResp_t")
local xp_bbp_messages_BbpUlPrbShareCalculationReq_t = require("xp/bbp/messages/BbpUlPrbShareCalculationReq_t")
local xp_bbp_messages_BbpUlPrbShareCalculationResp_t = require("xp/bbp/messages/BbpUlPrbShareCalculationResp_t")
local xp_bbp_messages_BbpPdschLayerShareCalculationReq_t = require("xp/bbp/messages/BbpPdschLayerShareCalculationReq_t")
local xp_bbp_messages_BbpPdschLayerShareCalculationResp_t = require("xp/bbp/messages/BbpPdschLayerShareCalculationResp_t")


function XpBbpMessage_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpBbpMessage_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_bbp_messages_BbPoolingConfiguredCapacityCalculationReq_t("bbPoolingConfiguredCapacityCalculationReq", 0),
            xp_bbp_messages_BbPoolingConfiguredCapacityCalculationResp_t("bbPoolingConfiguredCapacityCalculationResp", 0),
            xp_bbp_messages_BbpDlPrbShareCalculationReq_t("bbpDlPrbShareCalculationReq", 0),
            xp_bbp_messages_BbpDlPrbShareCalculationResp_t("bbpDlPrbShareCalculationResp", 0),
            xp_bbp_messages_BbpUlPrbShareCalculationReq_t("bbpUlPrbShareCalculationReq", 0),
            xp_bbp_messages_BbpUlPrbShareCalculationResp_t("bbpUlPrbShareCalculationResp", 0),
            xp_bbp_messages_BbpPdschLayerShareCalculationReq_t("bbpPdschLayerShareCalculationReq", 0),
            xp_bbp_messages_BbpPdschLayerShareCalculationResp_t("bbpPdschLayerShareCalculationResp", 0),
            },
            {0, 1, 2, 8, 9, 11, 12, 14, 15}
        )
end

return XpBbpMessage_t
