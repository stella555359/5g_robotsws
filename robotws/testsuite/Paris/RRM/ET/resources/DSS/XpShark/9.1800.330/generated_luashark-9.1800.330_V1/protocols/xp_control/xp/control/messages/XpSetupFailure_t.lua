-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_control_XpControlFailureCause_t = require("xp/control/XpControlFailureCause_t"),
      xp_common_TimeToWait = require("xp/common/TimeToWait"),
      xp_control_messages_XpSetupFailExtensions = require("xp/control/messages/XpSetupFailExtensions"),
}

function XpSetupFailure_t (fieldName, position)
    return
        fields.Structure({name="XpSetupFailure_t", fieldName=fieldName, position=position, size=20}, {
            fields.enumeration(
                {name="cause", position=0, enumTerm=localVarTable.xp_control_XpControlFailureCause_t},
                ProtoField.int32, 4, "int32"),
            fields.StaticVariableSizedArray({name="timeToWait", position=4, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=4, enumTerm=localVarTable.xp_common_TimeToWait},
                    ProtoField.int32, 4, "int32")
            ),
            localVarTable.xp_control_messages_XpSetupFailExtensions("extensions", 12),
        })
end

return XpSetupFailure_t
