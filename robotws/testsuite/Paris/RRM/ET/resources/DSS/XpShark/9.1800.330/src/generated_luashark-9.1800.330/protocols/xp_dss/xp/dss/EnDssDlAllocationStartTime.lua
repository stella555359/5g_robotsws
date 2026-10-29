-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
