-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_UlL1PoolConfiguration = require("xp/bbp/UlL1PoolConfiguration")
local xp_bbp_UlL1SubPoolConfigurationList = require("xp/bbp/UlL1SubPoolConfigurationList")
local xp_bbp_messages_BbpUlPrbShareCalculationReqExtensions = require("xp/bbp/messages/BbpUlPrbShareCalculationReqExtensions")


function BbpUlPrbShareCalculationReq_t (fieldName, position)
    return
        fields.Structure({name="BbpUlPrbShareCalculationReq_t", fieldName=fieldName, position=position, size=44}, {
            fields.uint32({name="l2PoolId", position=0}),
            fields.uint32({name="l1PoolId", position=4}),
            xp_bbp_UlL1PoolConfiguration("ulL1PoolConfiguration", 8),
            xp_bbp_UlL1SubPoolConfigurationList("ulL1SubPoolConfigurationList", 20),
            xp_bbp_messages_BbpUlPrbShareCalculationReqExtensions("extensions", 36),
        })
end

return BbpUlPrbShareCalculationReq_t
