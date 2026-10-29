-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_common_XpAddress_t = require("xp/common/XpAddress_t")
local xp_internal_messages_ERegCause = require("xp/internal/messages/ERegCause")


function EndpointState_t (fieldName, position)
    return
        fields.Structure({name="EndpointState_t", fieldName=fieldName, position=position, size=20}, {
            xp_common_XpAddress_t("xpAddress", 0),
            fields.enumeration(
                {name="regStatus", position=16, enumTerm=xp_internal_messages_ERegCause},
                ProtoField.int32, 4, "int32"),
        })
end

return EndpointState_t
