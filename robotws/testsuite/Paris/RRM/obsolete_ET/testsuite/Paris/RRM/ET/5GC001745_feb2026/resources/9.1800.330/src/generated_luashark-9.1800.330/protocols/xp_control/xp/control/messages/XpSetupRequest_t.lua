-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_MessageSet_t = require("xp/common/MessageSet_t")
local xp_control_messages_XpSetupReqExtensions = require("xp/control/messages/XpSetupReqExtensions")


function XpSetupRequest_t (fieldName, position)
    return
        fields.Structure({name="XpSetupRequest_t", fieldName=fieldName, position=position, size=16}, {
            fields.DynamicVariableSizedArray({name="messageSetList", position=0, size=8, numSizePaddingBytes=0, numItems=24, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_common_MessageSet_t("messageSetList", 0)
            ),
            xp_control_messages_XpSetupReqExtensions("extensions", 8),
        })
end

return XpSetupRequest_t
