-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_messages_BbPoolingConfiguredCapacityCalculationRespExtensions = require("xp/bbp/messages/BbPoolingConfiguredCapacityCalculationRespExtensions"),
}

function BbPoolingConfiguredCapacityCalculationResp_t (fieldName, position)
    return
        fields.Structure({name="BbPoolingConfiguredCapacityCalculationResp_t", fieldName=fieldName, position=position, size=20}, {
            fields.uint32({name="l2PoolId", position=0}),
            fields.uint32({name="l1PoolId", position=4}),
            fields.uint32({name="newL1SharingRatio", position=8}),
            localVarTable.xp_bbp_messages_BbPoolingConfiguredCapacityCalculationRespExtensions("extensions", 12),
        })
end

return BbPoolingConfiguredCapacityCalculationResp_t
