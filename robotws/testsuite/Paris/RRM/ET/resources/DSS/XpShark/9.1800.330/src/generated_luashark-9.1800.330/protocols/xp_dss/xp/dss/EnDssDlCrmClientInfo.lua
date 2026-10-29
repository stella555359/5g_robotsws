-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")


function EnDssDlCrmClientInfo (fieldName, position)
    return
        fields.Structure({name="EnDssDlCrmClientInfo", fieldName=fieldName, position=position, size=4}, {
            fields.uint16({name="enDssDlLoadMeasurementTimer", position=0}),
            fields.Padding({name="enDssDlLoadMeasurementTimer_padding", position=2, size=2}),
        })
end

return EnDssDlCrmClientInfo
