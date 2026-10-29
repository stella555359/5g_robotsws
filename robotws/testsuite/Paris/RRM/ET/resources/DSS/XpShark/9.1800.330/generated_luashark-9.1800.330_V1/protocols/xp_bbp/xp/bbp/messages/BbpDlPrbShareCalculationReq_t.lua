-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_DlL1PoolConfiguration = require("xp/bbp/DlL1PoolConfiguration"),
      xp_bbp_DlL1SubPoolConfigurationList = require("xp/bbp/DlL1SubPoolConfigurationList"),
      xp_bbp_messages_BbpDlPrbShareCalculationReqExtensions = require("xp/bbp/messages/BbpDlPrbShareCalculationReqExtensions"),
}

function BbpDlPrbShareCalculationReq_t (fieldName, position)
    return
        fields.Structure({name="BbpDlPrbShareCalculationReq_t", fieldName=fieldName, position=position, size=44}, {
            fields.uint32({name="l2PoolId", position=0}),
            fields.uint32({name="l1PoolId", position=4}),
            localVarTable.xp_bbp_DlL1PoolConfiguration("dlL1PoolConfiguration", 8),
            localVarTable.xp_bbp_DlL1SubPoolConfigurationList("dlL1SubPoolConfigurationList", 20),
            localVarTable.xp_bbp_messages_BbpDlPrbShareCalculationReqExtensions("extensions", 36),
        })
end

return BbpDlPrbShareCalculationReq_t
