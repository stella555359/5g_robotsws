-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_XpAddress_t = require("xp/common/XpAddress_t"),
      xp_internal_messages_InternalAddress_t = require("xp/internal/messages/InternalAddress_t"),
      xp_common_ProtocolId = require("xp/common/ProtocolId"),
}

function Endpoint_t (fieldName, position)
    return
        fields.Structure({name="Endpoint_t", fieldName=fieldName, position=position, size=60}, {
            localVarTable.xp_common_XpAddress_t("xpAddress", 0),
            localVarTable.xp_internal_messages_InternalAddress_t("endPointInternalAddress", 16),
            fields.StaticVariableSizedArray({name="allowedProtocolIds", position=24, size=36, numSizePaddingBytes=0, numItems=16, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=24, enumTerm=localVarTable.xp_common_ProtocolId},
                    ProtoField.uint16, 2, "uint16")
            ),
        })
end

return Endpoint_t
