-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_internal_EResult = require("xp/internal/EResult")
local xp_internal_messages_EndpointState_t = require("xp/internal/messages/EndpointState_t")


function XpIntl_Register_Rsp_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_Register_Rsp_t", fieldName=fieldName, position=position, size=20}, {
            fields.enumeration(
                {name="result", position=0, enumTerm=xp_internal_EResult},
                ProtoField.int32, 4, "int32"),
            fields.StaticVariableSizedArray({name="xpEventQueueId", position=4, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.uint32({name="item", position=4})
            ),
            fields.DynamicVariableSizedArray({name="allowedEndpoints", position=12, size=8, numSizePaddingBytes=0, numItems=255, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_internal_messages_EndpointState_t("allowedEndpoints", 12)
            ),
        })
end

return XpIntl_Register_Rsp_t
