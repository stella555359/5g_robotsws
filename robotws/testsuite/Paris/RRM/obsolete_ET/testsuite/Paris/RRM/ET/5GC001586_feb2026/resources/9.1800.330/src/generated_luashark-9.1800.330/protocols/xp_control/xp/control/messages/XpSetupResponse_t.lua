-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_common_MessageSet_t = require("xp/common/MessageSet_t")
local xp_control_messages_XpSetupRespExtensions = require("xp/control/messages/XpSetupRespExtensions")


function XpSetupResponse_t (fieldName, position)
    return
        fields.Structure({name="XpSetupResponse_t", fieldName=fieldName, position=position, size=36}, {
            xp_common_MessageSet_t("messageSet", 0),
            xp_control_messages_XpSetupRespExtensions("extensions", 28),
        })
end

return XpSetupResponse_t
