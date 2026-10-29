-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
