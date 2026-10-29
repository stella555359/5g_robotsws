-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_internal_messages_Endpoint_t = require("xp/internal/messages/Endpoint_t")


function XpIntl_Register_Req_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_Register_Req_t", fieldName=fieldName, position=position, size=8}, {
            fields.DynamicVariableSizedArray({name="allowedEndpoints", position=0, size=8, numSizePaddingBytes=0, numItems=255, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_internal_messages_Endpoint_t("allowedEndpoints", 0)
            ),
        })
end

return XpIntl_Register_Req_t
