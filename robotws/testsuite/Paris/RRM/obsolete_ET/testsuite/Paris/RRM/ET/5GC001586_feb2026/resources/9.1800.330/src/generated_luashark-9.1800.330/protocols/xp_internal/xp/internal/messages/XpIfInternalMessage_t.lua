-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_internal_messages_XpIntl_Register_Req_t = require("xp/internal/messages/XpIntl_Register_Req_t")
local xp_internal_messages_XpIntl_Register_Rsp_t = require("xp/internal/messages/XpIntl_Register_Rsp_t")
local xp_internal_messages_XpIntl_DeRegister_Req_t = require("xp/internal/messages/XpIntl_DeRegister_Req_t")
local xp_internal_messages_XpIntl_DeRegister_Rsp_t = require("xp/internal/messages/XpIntl_DeRegister_Rsp_t")
local xp_internal_messages_XpIntl_ConnStatus_Subscribe_Req_t = require("xp/internal/messages/XpIntl_ConnStatus_Subscribe_Req_t")
local xp_internal_messages_XpIntl_ConnStatus_Subscribe_Rsp_t = require("xp/internal/messages/XpIntl_ConnStatus_Subscribe_Rsp_t")
local xp_internal_messages_XpIntl_ConnStatus_Unsubscribe_Req_t = require("xp/internal/messages/XpIntl_ConnStatus_Unsubscribe_Req_t")
local xp_internal_messages_XpIntl_ConnStatus_Unsubscribe_Rsp_t = require("xp/internal/messages/XpIntl_ConnStatus_Unsubscribe_Rsp_t")
local xp_internal_messages_XpIntl_Get_ConnStatus_t = require("xp/internal/messages/XpIntl_Get_ConnStatus_t")
local xp_internal_messages_XpIntl_ConnStatus_Indication_t = require("xp/internal/messages/XpIntl_ConnStatus_Indication_t")
local xp_internal_messages_XpIntl_Error_Indication_t = require("xp/internal/messages/XpIntl_Error_Indication_t")


function XpIfInternalMessage_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpIfInternalMessage_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_internal_messages_XpIntl_Register_Req_t("xpIntl_Register_Request", 0),
            xp_internal_messages_XpIntl_Register_Rsp_t("xpIntl_Register_Response", 0),
            xp_internal_messages_XpIntl_DeRegister_Req_t("xpIntl_DeRegister_Request", 0),
            xp_internal_messages_XpIntl_DeRegister_Rsp_t("xpIntl_DeRegister_Response", 0),
            xp_internal_messages_XpIntl_ConnStatus_Subscribe_Req_t("xpIntl_ConnStatus_Subscribe_Request", 0),
            xp_internal_messages_XpIntl_ConnStatus_Subscribe_Rsp_t("xpIntl_ConnStatus_Subscribe_Response", 0),
            xp_internal_messages_XpIntl_ConnStatus_Unsubscribe_Req_t("xpIntl_ConnStatus_Unsubscribe_Request", 0),
            xp_internal_messages_XpIntl_ConnStatus_Unsubscribe_Rsp_t("xpIntl_ConnStatus_Unsubscribe_Response", 0),
            xp_internal_messages_XpIntl_Get_ConnStatus_t("xpIntl_Get_ConnStatus", 0),
            xp_internal_messages_XpIntl_ConnStatus_Indication_t("xpIntl_ConnStatus_Indication", 0),
            xp_internal_messages_XpIntl_Error_Indication_t("xpIntl_Error_Indication", 0),
            },
            {255, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
        )
end

return XpIfInternalMessage_t
