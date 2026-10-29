-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
