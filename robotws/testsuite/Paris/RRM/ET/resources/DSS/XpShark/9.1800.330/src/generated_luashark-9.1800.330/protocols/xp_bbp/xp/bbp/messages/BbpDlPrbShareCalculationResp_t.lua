-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_bbp_DlL1SubPoolAssignmentList = require("xp/bbp/DlL1SubPoolAssignmentList")
local xp_bbp_BbpAllocationStartTime = require("xp/bbp/BbpAllocationStartTime")
local xp_bbp_messages_BbpDlPrbShareCalculationRespExtensions = require("xp/bbp/messages/BbpDlPrbShareCalculationRespExtensions")


function BbpDlPrbShareCalculationResp_t (fieldName, position)
    return
        fields.Structure({name="BbpDlPrbShareCalculationResp_t", fieldName=fieldName, position=position, size=40}, {
            fields.uint32({name="l2PoolId", position=0}),
            fields.uint32({name="l1PoolId", position=4}),
            xp_bbp_DlL1SubPoolAssignmentList("dlL1SubPoolAssignmentList", 8),
            xp_bbp_BbpAllocationStartTime("dlAllocationStartTime", 24),
            xp_bbp_messages_BbpDlPrbShareCalculationRespExtensions("extensions", 32),
        })
end

return BbpDlPrbShareCalculationResp_t
