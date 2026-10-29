-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_epXpControlMsg = require("xp/common/epXpControlMsg"),
      xp_common_epDssMsg = require("xp/common/epDssMsg"),
      xp_common_epInternalMsg = require("xp/common/epInternalMsg"),
      xp_common_epBbpMsg = require("xp/common/epBbpMsg"),
      xp_common_epFastpathMsg = require("xp/common/epFastpathMsg"),
      xp_common_epCellConfigMsg = require("xp/common/epCellConfigMsg"),
}

function XpPayload_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpPayload_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            localVarTable.xp_common_epXpControlMsg("controlMsg", 0),
            localVarTable.xp_common_epDssMsg("dssMsg", 0),
            localVarTable.xp_common_epInternalMsg("internalMsg", 0),
            localVarTable.xp_common_epBbpMsg("bbpMsg", 0),
            localVarTable.xp_common_epFastpathMsg("fastpathMsg", 0),
            localVarTable.xp_common_epCellConfigMsg("cellConfigMsg", 0),
            },
            {0, 1, 2, 3, 4, 5, 6}
        )
end

return XpPayload_t
