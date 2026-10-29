-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
