-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
