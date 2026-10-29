-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")


function BbpAllocationStartTime (fieldName, position)
    return
        fields.Structure({name="BbpAllocationStartTime", fieldName=fieldName, position=position, size=8}, {
            fields.uint16({name="bbpAllocationStartHyperframeNumber", position=0}),
            fields.uint16({name="bbpAllocationStartSystemFrameNumber", position=2}),
            fields.uint8({name="bbpAllocationStartSubframeNumber", position=4}),
            fields.Padding({name="bbpAllocationStartSubframeNumber_padding", position=5, size=3}),
        })
end

return BbpAllocationStartTime
