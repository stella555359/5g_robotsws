-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_CrmId = require("xp/common/CrmId")


function EndpointIdentifier_t (fieldName, position)
    return
        fields.DynamicUnion({name="EndpointIdentifier_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            fields.void({name="noIdentifier", position=0}),
            fields.uint32({name="eNBCellId", position=0}),
            fields.uint32({name="gNBCellId", position=0}),
            xp_common_CrmId("crmId", 0),
            },
            {255, 1, 2, 3, 4}
        )
end

return EndpointIdentifier_t
