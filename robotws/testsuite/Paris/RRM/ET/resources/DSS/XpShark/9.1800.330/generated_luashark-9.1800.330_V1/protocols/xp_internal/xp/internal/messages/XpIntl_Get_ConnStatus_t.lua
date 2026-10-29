-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_NEIdentifier_t = require("xp/common/NEIdentifier_t"),
}

function XpIntl_Get_ConnStatus_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_Get_ConnStatus_t", fieldName=fieldName, position=position, size=8}, {
            localVarTable.xp_common_NEIdentifier_t("neid", 0),
        })
end

return XpIntl_Get_ConnStatus_t
