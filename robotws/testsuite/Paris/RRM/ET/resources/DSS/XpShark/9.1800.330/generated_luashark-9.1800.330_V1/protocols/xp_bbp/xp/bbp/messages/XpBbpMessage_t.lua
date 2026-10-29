-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_messages_BbPoolingConfiguredCapacityCalculationReq_t = require("xp/bbp/messages/BbPoolingConfiguredCapacityCalculationReq_t"),
      xp_bbp_messages_BbPoolingConfiguredCapacityCalculationResp_t = require("xp/bbp/messages/BbPoolingConfiguredCapacityCalculationResp_t"),
      xp_bbp_messages_BbpDlPrbShareCalculationReq_t = require("xp/bbp/messages/BbpDlPrbShareCalculationReq_t"),
      xp_bbp_messages_BbpDlPrbShareCalculationResp_t = require("xp/bbp/messages/BbpDlPrbShareCalculationResp_t"),
      xp_bbp_messages_BbpUlPrbShareCalculationReq_t = require("xp/bbp/messages/BbpUlPrbShareCalculationReq_t"),
      xp_bbp_messages_BbpUlPrbShareCalculationResp_t = require("xp/bbp/messages/BbpUlPrbShareCalculationResp_t"),
}

function XpBbpMessage_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpBbpMessage_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            localVarTable.xp_bbp_messages_BbPoolingConfiguredCapacityCalculationReq_t("bbPoolingConfiguredCapacityCalculationReq", 0),
            localVarTable.xp_bbp_messages_BbPoolingConfiguredCapacityCalculationResp_t("bbPoolingConfiguredCapacityCalculationResp", 0),
            localVarTable.xp_bbp_messages_BbpDlPrbShareCalculationReq_t("bbpDlPrbShareCalculationReq", 0),
            localVarTable.xp_bbp_messages_BbpDlPrbShareCalculationResp_t("bbpDlPrbShareCalculationResp", 0),
            localVarTable.xp_bbp_messages_BbpUlPrbShareCalculationReq_t("bbpUlPrbShareCalculationReq", 0),
            localVarTable.xp_bbp_messages_BbpUlPrbShareCalculationResp_t("bbpUlPrbShareCalculationResp", 0),
            },
            {0, 1, 2, 8, 9, 11, 12}
        )
end

return XpBbpMessage_t
