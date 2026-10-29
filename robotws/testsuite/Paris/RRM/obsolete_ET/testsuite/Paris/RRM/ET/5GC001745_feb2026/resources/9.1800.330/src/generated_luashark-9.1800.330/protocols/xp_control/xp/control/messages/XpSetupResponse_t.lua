-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
