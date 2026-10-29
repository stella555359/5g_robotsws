-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_NEIdentifier_t = require("xp/common/NEIdentifier_t"),
      xp_internal_messages_InternalAddress_t = require("xp/internal/messages/InternalAddress_t"),
}

function XpIntl_ConnStatus_Subscribe_Req_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_ConnStatus_Subscribe_Req_t", fieldName=fieldName, position=position, size=16}, {
            localVarTable.xp_common_NEIdentifier_t("neid", 0),
            fields.DynamicVariableSizedArray({name="allowedEndpoints", position=8, size=8, numSizePaddingBytes=0, numItems=255, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_internal_messages_InternalAddress_t("allowedEndpoints", 8)
            ),
        })
end

return XpIntl_ConnStatus_Subscribe_Req_t
