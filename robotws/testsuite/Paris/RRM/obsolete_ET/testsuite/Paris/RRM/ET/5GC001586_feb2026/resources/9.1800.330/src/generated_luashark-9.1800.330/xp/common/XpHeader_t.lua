-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_common_ProtocolId = require("xp/common/ProtocolId")
local xp_common_XpAddress_t = require("xp/common/XpAddress_t")
local xp_common_XpHeaderExtensions = require("xp/common/XpHeaderExtensions")


function XpHeader_t (fieldName, position)
    return
        fields.Structure({name="XpHeader_t", fieldName=fieldName, position=position, size=44}, {
            fields.enumeration(
                {name="protocolId", position=0, enumTerm=xp_common_ProtocolId},
                ProtoField.uint16, 2, "uint16"),
            fields.Padding({name="protocolId_source_padding", position=2, size=2}),
            xp_common_XpAddress_t("source", 4),
            xp_common_XpAddress_t("destination", 20),
            xp_common_XpHeaderExtensions("ext_field", 36),
        })
end

return XpHeader_t
