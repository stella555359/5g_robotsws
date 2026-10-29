-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_PLMNId_t = require("xp/common/PLMNId_t"),
}

function GlobalgNBId_t (fieldName, position)
    return
        fields.Structure({name="GlobalgNBId_t", fieldName=fieldName, position=position, size=8}, {
            localVarTable.xp_common_PLMNId_t("plmnId", 0),
            fields.uint32({name="gNBId", position=4}),
        })
end

return GlobalgNBId_t
