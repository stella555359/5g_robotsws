-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_XpAddress_t = require("xp/common/XpAddress_t"),
      xp_internal_messages_ERegCause = require("xp/internal/messages/ERegCause"),
}

function EndpointState_t (fieldName, position)
    return
        fields.Structure({name="EndpointState_t", fieldName=fieldName, position=position, size=20}, {
            localVarTable.xp_common_XpAddress_t("xpAddress", 0),
            fields.enumeration(
                {name="regStatus", position=16, enumTerm=localVarTable.xp_internal_messages_ERegCause},
                ProtoField.int32, 4, "int32"),
        })
end

return EndpointState_t
