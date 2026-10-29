-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_bbp_messages_BbPoolingConfiguredCapacityCalculationReq_t = require("xp/bbp/messages/BbPoolingConfiguredCapacityCalculationReq_t")
local xp_bbp_messages_BbPoolingConfiguredCapacityCalculationResp_t = require("xp/bbp/messages/BbPoolingConfiguredCapacityCalculationResp_t")


function XpBbpMessage_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpBbpMessage_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_bbp_messages_BbPoolingConfiguredCapacityCalculationReq_t("bbPoolingConfiguredCapacityCalculationReq", 0),
            xp_bbp_messages_BbPoolingConfiguredCapacityCalculationResp_t("bbPoolingConfiguredCapacityCalculationResp", 0),
            },
            {0, 1, 2}
        )
end

return XpBbpMessage_t
