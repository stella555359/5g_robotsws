-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
