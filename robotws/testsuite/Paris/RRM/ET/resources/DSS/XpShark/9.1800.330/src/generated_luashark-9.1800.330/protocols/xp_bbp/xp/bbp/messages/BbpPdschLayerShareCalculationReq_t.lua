-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_L1PoolPdschLayerConfiguration = require("xp/bbp/L1PoolPdschLayerConfiguration")
local xp_bbp_L1SubPoolPdschLayerConfigurationList = require("xp/bbp/L1SubPoolPdschLayerConfigurationList")
local xp_bbp_messages_BbpPdschLayerShareCalculationReqExtensions = require("xp/bbp/messages/BbpPdschLayerShareCalculationReqExtensions")


function BbpPdschLayerShareCalculationReq_t (fieldName, position)
    return
        fields.Structure({name="BbpPdschLayerShareCalculationReq_t", fieldName=fieldName, position=position, size=44}, {
            fields.uint32({name="l1PoolId", position=0}),
            fields.uint32({name="l2PoolId", position=4}),
            xp_bbp_L1PoolPdschLayerConfiguration("l1PoolPdschLayerConfiguration", 8),
            xp_bbp_L1SubPoolPdschLayerConfigurationList("l1SubPoolPdschLayerConfigurationList", 20),
            xp_bbp_messages_BbpPdschLayerShareCalculationReqExtensions("extensions", 36),
        })
end

return BbpPdschLayerShareCalculationReq_t
