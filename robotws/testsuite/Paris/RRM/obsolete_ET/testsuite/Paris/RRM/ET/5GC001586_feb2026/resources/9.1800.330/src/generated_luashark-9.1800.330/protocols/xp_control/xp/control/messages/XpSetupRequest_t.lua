-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
