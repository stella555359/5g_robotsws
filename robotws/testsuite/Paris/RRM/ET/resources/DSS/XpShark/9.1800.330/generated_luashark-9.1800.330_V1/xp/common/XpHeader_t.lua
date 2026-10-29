-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_ProtocolId = require("xp/common/ProtocolId"),
      xp_common_XpAddress_t = require("xp/common/XpAddress_t"),
      xp_common_XpHeaderExtensions = require("xp/common/XpHeaderExtensions"),
}

function XpHeader_t (fieldName, position)
    return
        fields.Structure({name="XpHeader_t", fieldName=fieldName, position=position, size=44}, {
            fields.enumeration(
                {name="protocolId", position=0, enumTerm=localVarTable.xp_common_ProtocolId},
                ProtoField.uint16, 2, "uint16"),
            fields.Padding({name="protocolId_source_padding", position=2, size=2}),
            localVarTable.xp_common_XpAddress_t("source", 4),
            localVarTable.xp_common_XpAddress_t("destination", 20),
            localVarTable.xp_common_XpHeaderExtensions("ext_field", 36),
        })
end

return XpHeader_t
