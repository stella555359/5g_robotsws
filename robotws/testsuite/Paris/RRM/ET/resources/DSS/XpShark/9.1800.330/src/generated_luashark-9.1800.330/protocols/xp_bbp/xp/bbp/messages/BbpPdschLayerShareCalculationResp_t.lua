-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_L1SubPoolPdschLayerAssignmentList = require("xp/bbp/L1SubPoolPdschLayerAssignmentList")
local xp_bbp_BbpAllocationStartTime = require("xp/bbp/BbpAllocationStartTime")
local xp_bbp_messages_BbpPdschLayerShareCalculationRespExtensions = require("xp/bbp/messages/BbpPdschLayerShareCalculationRespExtensions")


function BbpPdschLayerShareCalculationResp_t (fieldName, position)
    return
        fields.Structure({name="BbpPdschLayerShareCalculationResp_t", fieldName=fieldName, position=position, size=40}, {
            fields.uint32({name="l1PoolId", position=0}),
            fields.uint32({name="l2PoolId", position=4}),
            xp_bbp_L1SubPoolPdschLayerAssignmentList("l1SubPoolPdschLayerAssignmentList", 8),
            xp_bbp_BbpAllocationStartTime("dlAllocationStartTime", 24),
            xp_bbp_messages_BbpPdschLayerShareCalculationRespExtensions("extensions", 32),
        })
end

return BbpPdschLayerShareCalculationResp_t
