-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_XpAddress_t = require("xp/common/XpAddress_t")
local xp_internal_messages_InternalAddress_t = require("xp/internal/messages/InternalAddress_t")
local xp_common_ProtocolId = require("xp/common/ProtocolId")


function Endpoint_t (fieldName, position)
    return
        fields.Structure({name="Endpoint_t", fieldName=fieldName, position=position, size=60}, {
            xp_common_XpAddress_t("xpAddress", 0),
            xp_internal_messages_InternalAddress_t("endPointInternalAddress", 16),
            fields.StaticVariableSizedArray({name="allowedProtocolIds", position=24, size=36, numSizePaddingBytes=0, numItems=16, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=24, enumTerm=xp_common_ProtocolId},
                    ProtoField.uint16, 2, "uint16")
            ),
        })
end

return Endpoint_t
