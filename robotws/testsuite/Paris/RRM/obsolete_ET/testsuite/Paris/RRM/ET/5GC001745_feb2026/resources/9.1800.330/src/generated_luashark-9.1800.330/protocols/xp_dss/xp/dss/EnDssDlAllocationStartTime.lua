-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")


-- The start time is expressed with the hyperframe number and the system frame number. The recipient shall evaluate the hyperframe number and the system frame number and compare it with its own current hyperframe number and systemframe number.
--      As the received hyperframe number and system frame number are ambiguous (they may mark several points in time in different epochs of the hyperframe), the receiver interprets it to be the closest of those points in time. The assumed point in time may be in the past or in the future.
--      Note: When used in messageset DMS3 the usage of 0xFFFF is depreciated.
function EnDssDlAllocationStartTime (fieldName, position)
    return
        fields.Structure({name="EnDssDlAllocationStartTime", fieldName=fieldName, position=position, size=4}, {
            fields.uint16({name="enDssDlAllocationStartHyperframeNumber", position=0}),
            fields.uint16({name="enDssDlAllocationStartSystemFrameNumber", position=2}),
        })
end

return EnDssDlAllocationStartTime
