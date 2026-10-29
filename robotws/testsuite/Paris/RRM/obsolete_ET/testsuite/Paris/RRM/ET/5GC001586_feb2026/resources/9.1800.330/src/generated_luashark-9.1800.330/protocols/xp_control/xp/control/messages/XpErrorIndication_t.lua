-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_control_XpControlFailureCause_t = require("xp/control/XpControlFailureCause_t")
local xp_control_messages_XpErrorIndExtensions = require("xp/control/messages/XpErrorIndExtensions")


function XpErrorIndication_t (fieldName, position)
    return
        fields.Structure({name="XpErrorIndication_t", fieldName=fieldName, position=position, size=12}, {
            fields.enumeration(
                {name="cause", position=0, enumTerm=xp_control_XpControlFailureCause_t},
                ProtoField.int32, 4, "int32"),
            xp_control_messages_XpErrorIndExtensions("extensions", 4),
        })
end

return XpErrorIndication_t
