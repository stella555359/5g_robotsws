-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
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
