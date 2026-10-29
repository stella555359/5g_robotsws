-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")


function EnDssDlLoadMeasurements (fieldName, position)
    return
        fields.Structure({name="EnDssDlLoadMeasurements", fieldName=fieldName, position=position, size=4}, {
            fields.uint8({name="measuredLoad", position=0}),
            fields.Padding({name="measuredLoad_padding", position=1, size=3}),
        })
end

return EnDssDlLoadMeasurements
