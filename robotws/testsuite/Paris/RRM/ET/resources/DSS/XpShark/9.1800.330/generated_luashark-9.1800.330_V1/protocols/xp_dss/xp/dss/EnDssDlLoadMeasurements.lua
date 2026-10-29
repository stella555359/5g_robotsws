-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")



function EnDssDlLoadMeasurements (fieldName, position)
    return
        fields.Structure({name="EnDssDlLoadMeasurements", fieldName=fieldName, position=position, size=4}, {
            fields.uint8({name="measuredLoad", position=0}),
            fields.Padding({name="measuredLoad_padding", position=1, size=3}),
        })
end

return EnDssDlLoadMeasurements
