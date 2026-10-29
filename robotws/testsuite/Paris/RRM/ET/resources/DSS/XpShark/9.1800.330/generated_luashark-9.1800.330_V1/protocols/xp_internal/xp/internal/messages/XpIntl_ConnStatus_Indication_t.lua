-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_NEIdentifier_t = require("xp/common/NEIdentifier_t"),
      xp_internal_messages_EConnStatus = require("xp/internal/messages/EConnStatus"),
}

function XpIntl_ConnStatus_Indication_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_ConnStatus_Indication_t", fieldName=fieldName, position=position, size=12}, {
            localVarTable.xp_common_NEIdentifier_t("neid", 0),
            fields.enumeration(
                {name="connStatus", position=8, enumTerm=localVarTable.xp_internal_messages_EConnStatus},
                ProtoField.int32, 4, "int32"),
        })
end

return XpIntl_ConnStatus_Indication_t
