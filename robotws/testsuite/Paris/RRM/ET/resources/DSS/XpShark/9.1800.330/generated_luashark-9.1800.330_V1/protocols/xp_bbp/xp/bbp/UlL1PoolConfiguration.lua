-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_bbp_UlL1PoolConfigurationExtensions = require("xp/bbp/UlL1PoolConfigurationExtensions"),
}

function UlL1PoolConfiguration (fieldName, position)
    return
        fields.Structure({name="UlL1PoolConfiguration", fieldName=fieldName, position=position, size=12}, {
            fields.uint16({name="maxUlPuschPrb", position=0}),
            fields.uint16({name="l1PoolUlPrbEquivalentRequest", position=2}),
            localVarTable.xp_bbp_UlL1PoolConfigurationExtensions("extensions", 4),
        })
end

return UlL1PoolConfiguration
