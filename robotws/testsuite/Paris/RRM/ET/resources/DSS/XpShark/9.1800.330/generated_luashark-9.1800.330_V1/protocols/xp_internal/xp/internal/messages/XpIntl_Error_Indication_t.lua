-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_internal_messages_EErrCode = require("xp/internal/messages/EErrCode"),
}

function XpIntl_Error_Indication_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_Error_Indication_t", fieldName=fieldName, position=position, size=4}, {
            fields.enumeration(
                {name="errorCode", position=0, enumTerm=localVarTable.xp_internal_messages_EErrCode},
                ProtoField.int32, 4, "int32"),
        })
end

return XpIntl_Error_Indication_t
