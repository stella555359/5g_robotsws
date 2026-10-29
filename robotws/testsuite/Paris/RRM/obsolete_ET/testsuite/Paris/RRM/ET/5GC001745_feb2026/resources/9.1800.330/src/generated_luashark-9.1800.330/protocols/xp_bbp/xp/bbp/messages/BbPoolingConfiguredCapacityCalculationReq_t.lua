-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")


function BbPoolingConfiguredCapacityCalculationReq_t (fieldName, position)
    return
        fields.Structure({name="BbPoolingConfiguredCapacityCalculationReq_t", fieldName=fieldName, position=position, size=16}, {
            fields.uint32({name="l2PoolId", position=0}),
            fields.uint32({name="l1PoolId", position=4}),
            fields.uint32({name="minConfiguredL1Capacity", position=8}),
            fields.uint32({name="l2PoolAverageLoad", position=12}),
        })
end

return BbPoolingConfiguredCapacityCalculationReq_t
