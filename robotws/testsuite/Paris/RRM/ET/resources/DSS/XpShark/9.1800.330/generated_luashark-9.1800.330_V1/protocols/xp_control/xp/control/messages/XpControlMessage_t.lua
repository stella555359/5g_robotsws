-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_control_messages_XpErrorIndication_t = require("xp/control/messages/XpErrorIndication_t"),
      xp_control_messages_XpSetupRequest_t = require("xp/control/messages/XpSetupRequest_t"),
      xp_control_messages_XpSetupResponse_t = require("xp/control/messages/XpSetupResponse_t"),
      xp_control_messages_XpSetupFailure_t = require("xp/control/messages/XpSetupFailure_t"),
}

function XpControlMessage_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpControlMessage_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            localVarTable.xp_control_messages_XpErrorIndication_t("xpErrorIndication", 0),
            localVarTable.xp_control_messages_XpSetupRequest_t("xpSetupRequest", 0),
            localVarTable.xp_control_messages_XpSetupResponse_t("xpSetupResponse", 0),
            localVarTable.xp_control_messages_XpSetupFailure_t("xpSetupFailure", 0),
            },
            {255, 1, 2, 3, 4}
        )
end

return XpControlMessage_t
