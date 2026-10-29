-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
