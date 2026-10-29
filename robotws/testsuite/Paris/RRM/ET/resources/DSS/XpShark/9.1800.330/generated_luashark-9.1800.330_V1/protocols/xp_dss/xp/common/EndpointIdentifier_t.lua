-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_common_CrmId = require("xp/common/CrmId"),
}

function EndpointIdentifier_t (fieldName, position)
    return
        fields.DynamicUnion({name="EndpointIdentifier_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            fields.void({name="noIdentifier", position=0}),
            fields.uint32({name="eNBCellId", position=0}),
            fields.uint32({name="gNBCellId", position=0}),
            localVarTable.xp_common_CrmId("crmId", 0),
            fields.uint32({name="bbpmId", position=0}),
            },
            {255, 1, 2, 3, 4, 5}
        )
end

return EndpointIdentifier_t
