-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
