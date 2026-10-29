-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_messages_BbPoolingConfiguredCapacityCalculationReqExtensions = require("xp/bbp/messages/BbPoolingConfiguredCapacityCalculationReqExtensions"),
}

function BbPoolingConfiguredCapacityCalculationReq_t (fieldName, position)
    return
        fields.Structure({name="BbPoolingConfiguredCapacityCalculationReq_t", fieldName=fieldName, position=position, size=24}, {
            fields.uint32({name="l2PoolId", position=0}),
            fields.uint32({name="l1PoolId", position=4}),
            fields.uint32({name="minConfiguredL1Capacity", position=8}),
            fields.uint32({name="l2PoolAverageLoad", position=12}),
            localVarTable.xp_bbp_messages_BbPoolingConfiguredCapacityCalculationReqExtensions("extensions", 16),
        })
end

return BbPoolingConfiguredCapacityCalculationReq_t
