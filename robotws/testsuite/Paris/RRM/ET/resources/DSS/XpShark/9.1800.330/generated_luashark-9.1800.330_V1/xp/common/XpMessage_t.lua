-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_XpHeader_t = require("xp/common/XpHeader_t"),
      xp_common_XpPayload_t = require("xp/common/XpPayload_t"),
      xp_common_XpMessageExtensions = require("xp/common/XpMessageExtensions"),
}

function XpMessage_t (fieldName, position)
    return
        fields.Structure({name="XpMessage_t", fieldName=fieldName, position=position, size=60}, {
            localVarTable.xp_common_XpHeader_t("XpHeader", 0),
            localVarTable.xp_common_XpPayload_t("XpPayload", 44),
            localVarTable.xp_common_XpMessageExtensions("extensions", 52),
        })
end

return XpMessage_t
