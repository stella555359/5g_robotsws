-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
