-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_internal_EResult = require("xp/internal/EResult"),
      xp_internal_messages_EndpointState_t = require("xp/internal/messages/EndpointState_t"),
}

function XpIntl_Register_Rsp_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_Register_Rsp_t", fieldName=fieldName, position=position, size=20}, {
            fields.enumeration(
                {name="result", position=0, enumTerm=localVarTable.xp_internal_EResult},
                ProtoField.int32, 4, "int32"),
            fields.StaticVariableSizedArray({name="xpEventQueueId", position=4, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.uint32({name="item", position=4})
            ),
            fields.DynamicVariableSizedArray({name="allowedEndpoints", position=12, size=8, numSizePaddingBytes=0, numItems=255, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_internal_messages_EndpointState_t("allowedEndpoints", 12)
            ),
        })
end

return XpIntl_Register_Rsp_t
