-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_DlL1SubPoolAssignmentList = require("xp/bbp/DlL1SubPoolAssignmentList"),
      xp_bbp_BbpAllocationStartTime = require("xp/bbp/BbpAllocationStartTime"),
      xp_bbp_messages_BbpDlPrbShareCalculationRespExtensions = require("xp/bbp/messages/BbpDlPrbShareCalculationRespExtensions"),
}

function BbpDlPrbShareCalculationResp_t (fieldName, position)
    return
        fields.Structure({name="BbpDlPrbShareCalculationResp_t", fieldName=fieldName, position=position, size=40}, {
            fields.uint32({name="l2PoolId", position=0}),
            fields.uint32({name="l1PoolId", position=4}),
            localVarTable.xp_bbp_DlL1SubPoolAssignmentList("dlL1SubPoolAssignmentList", 8),
            localVarTable.xp_bbp_BbpAllocationStartTime("dlAllocationStartTime", 24),
            localVarTable.xp_bbp_messages_BbpDlPrbShareCalculationRespExtensions("extensions", 32),
        })
end

return BbpDlPrbShareCalculationResp_t
