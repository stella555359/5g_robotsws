-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_internal_messages_Endpoint_t = require("xp/internal/messages/Endpoint_t")


function XpIntl_DeRegister_Req_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_DeRegister_Req_t", fieldName=fieldName, position=position, size=8}, {
            fields.DynamicVariableSizedArray({name="allowedEndpoints", position=0, size=8, numSizePaddingBytes=0, numItems=255, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_internal_messages_Endpoint_t("allowedEndpoints", 0)
            ),
        })
end

return XpIntl_DeRegister_Req_t
