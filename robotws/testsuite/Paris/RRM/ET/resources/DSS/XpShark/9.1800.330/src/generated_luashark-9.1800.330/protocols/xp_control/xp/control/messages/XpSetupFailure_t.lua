-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_control_XpControlFailureCause_t = require("xp/control/XpControlFailureCause_t")
local xp_common_TimeToWait = require("xp/common/TimeToWait")
local xp_control_messages_XpSetupFailExtensions = require("xp/control/messages/XpSetupFailExtensions")


function XpSetupFailure_t (fieldName, position)
    return
        fields.Structure({name="XpSetupFailure_t", fieldName=fieldName, position=position, size=20}, {
            fields.enumeration(
                {name="cause", position=0, enumTerm=xp_control_XpControlFailureCause_t},
                ProtoField.int32, 4, "int32"),
            fields.StaticVariableSizedArray({name="timeToWait", position=4, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=4, enumTerm=xp_common_TimeToWait},
                    ProtoField.int32, 4, "int32")
            ),
            xp_control_messages_XpSetupFailExtensions("extensions", 12),
        })
end

return XpSetupFailure_t
