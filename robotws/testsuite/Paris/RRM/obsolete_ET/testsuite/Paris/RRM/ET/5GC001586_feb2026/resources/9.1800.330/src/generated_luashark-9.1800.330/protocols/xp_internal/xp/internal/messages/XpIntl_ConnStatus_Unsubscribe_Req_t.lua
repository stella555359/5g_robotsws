-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_common_NEIdentifier_t = require("xp/common/NEIdentifier_t")
local xp_internal_messages_InternalAddress_t = require("xp/internal/messages/InternalAddress_t")


function XpIntl_ConnStatus_Unsubscribe_Req_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_ConnStatus_Unsubscribe_Req_t", fieldName=fieldName, position=position, size=16}, {
            xp_common_NEIdentifier_t("neid", 0),
            fields.DynamicVariableSizedArray({name="allowedEndpoints", position=8, size=8, numSizePaddingBytes=0, numItems=255, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_internal_messages_InternalAddress_t("allowedEndpoints", 8)
            ),
        })
end

return XpIntl_ConnStatus_Unsubscribe_Req_t
