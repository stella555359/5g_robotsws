-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_messages_BbPoolingConfiguredCapacityCalculationRespExtensions = require("xp/bbp/messages/BbPoolingConfiguredCapacityCalculationRespExtensions")


function BbPoolingConfiguredCapacityCalculationResp_t (fieldName, position)
    return
        fields.Structure({name="BbPoolingConfiguredCapacityCalculationResp_t", fieldName=fieldName, position=position, size=20}, {
            fields.uint32({name="l2PoolId", position=0}),
            fields.uint32({name="l1PoolId", position=4}),
            fields.uint32({name="newL1SharingRatio", position=8}),
            xp_bbp_messages_BbPoolingConfiguredCapacityCalculationRespExtensions("extensions", 12),
        })
end

return BbPoolingConfiguredCapacityCalculationResp_t
