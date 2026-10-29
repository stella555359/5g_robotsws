-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
