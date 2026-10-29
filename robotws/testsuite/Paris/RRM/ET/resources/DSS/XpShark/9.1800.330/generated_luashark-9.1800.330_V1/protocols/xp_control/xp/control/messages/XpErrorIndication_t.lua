-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_control_XpControlFailureCause_t = require("xp/control/XpControlFailureCause_t"),
      xp_control_messages_XpErrorIndExtensions = require("xp/control/messages/XpErrorIndExtensions"),
}

function XpErrorIndication_t (fieldName, position)
    return
        fields.Structure({name="XpErrorIndication_t", fieldName=fieldName, position=position, size=12}, {
            fields.enumeration(
                {name="cause", position=0, enumTerm=localVarTable.xp_control_XpControlFailureCause_t},
                ProtoField.int32, 4, "int32"),
            localVarTable.xp_control_messages_XpErrorIndExtensions("extensions", 4),
        })
end

return XpErrorIndication_t
