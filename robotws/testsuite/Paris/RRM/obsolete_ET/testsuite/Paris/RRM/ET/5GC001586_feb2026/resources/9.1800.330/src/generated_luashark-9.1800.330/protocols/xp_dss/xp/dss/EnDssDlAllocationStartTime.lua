-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")


-- The start time is expressed with the hyperframe number and the system frame number. The recipient shall evaluate the hyperframe number and the system frame number and compare it with its own current hyperframe number and systemframe number.
--      As the received hyperframe number and system frame number are ambiguous (they may mark several points in time in different epochs of the hyperframe), the receiver interprets it to be the closest of those points in time. The assumed point in time may be in the past or in the future.
function EnDssDlAllocationStartTime (fieldName, position)
    return
        fields.Structure({name="EnDssDlAllocationStartTime", fieldName=fieldName, position=position, size=4}, {
            fields.uint16({name="enDssDlAllocationStartHyperframeNumber", position=0}),
            fields.uint16({name="enDssDlAllocationStartSystemFrameNumber", position=2}),
        })
end

return EnDssDlAllocationStartTime
