-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_MessageSet_t = require("xp/common/MessageSet_t"),
      xp_control_messages_XpSetupReqExtensions = require("xp/control/messages/XpSetupReqExtensions"),
}

function XpSetupRequest_t (fieldName, position)
    return
        fields.Structure({name="XpSetupRequest_t", fieldName=fieldName, position=position, size=16}, {
            fields.DynamicVariableSizedArray({name="messageSetList", position=0, size=8, numSizePaddingBytes=0, numItems=24, numPaddingBytes=0},
                fields.uint32, fields.uint32, localVarTable.xp_common_MessageSet_t("messageSetList", 0)
            ),
            localVarTable.xp_control_messages_XpSetupReqExtensions("extensions", 8),
        })
end

return XpSetupRequest_t
