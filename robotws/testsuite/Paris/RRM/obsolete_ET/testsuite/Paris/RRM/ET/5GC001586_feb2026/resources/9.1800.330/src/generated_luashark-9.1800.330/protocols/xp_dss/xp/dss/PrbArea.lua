-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")


function PrbArea (fieldName, position)
    return
        fields.Structure({name="PrbArea", fieldName=fieldName, position=position, size=4}, {
            fields.uint16({name="startPrb", position=0}),
            fields.uint16({name="amountOfPrb", position=2}),
        })
end

return PrbArea
