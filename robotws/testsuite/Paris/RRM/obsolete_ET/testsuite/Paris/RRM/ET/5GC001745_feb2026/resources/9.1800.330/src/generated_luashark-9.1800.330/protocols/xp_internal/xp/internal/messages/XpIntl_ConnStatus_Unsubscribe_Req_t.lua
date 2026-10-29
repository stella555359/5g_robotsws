-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
