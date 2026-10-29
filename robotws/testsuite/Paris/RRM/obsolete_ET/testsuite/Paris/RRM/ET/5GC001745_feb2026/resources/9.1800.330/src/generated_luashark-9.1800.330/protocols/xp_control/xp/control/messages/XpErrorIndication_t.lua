-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
