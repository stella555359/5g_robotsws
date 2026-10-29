-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
