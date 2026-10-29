-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_control_messages_XpErrorIndication_t = require("xp/control/messages/XpErrorIndication_t")
local xp_control_messages_XpSetupRequest_t = require("xp/control/messages/XpSetupRequest_t")
local xp_control_messages_XpSetupResponse_t = require("xp/control/messages/XpSetupResponse_t")
local xp_control_messages_XpSetupFailure_t = require("xp/control/messages/XpSetupFailure_t")


function XpControlMessage_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpControlMessage_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_control_messages_XpErrorIndication_t("xpErrorIndication", 0),
            xp_control_messages_XpSetupRequest_t("xpSetupRequest", 0),
            xp_control_messages_XpSetupResponse_t("xpSetupResponse", 0),
            xp_control_messages_XpSetupFailure_t("xpSetupFailure", 0),
            },
            {255, 1, 2, 3, 4}
        )
end

return XpControlMessage_t
