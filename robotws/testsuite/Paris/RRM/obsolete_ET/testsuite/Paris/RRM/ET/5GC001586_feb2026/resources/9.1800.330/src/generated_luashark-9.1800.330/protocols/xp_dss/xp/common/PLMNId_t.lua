-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")


function PLMNId_t (fieldName, position)
    return
        fields.Structure({name="PLMNId_t", fieldName=fieldName, position=position, size=4}, {
            fields.StaticFixedSizedArray({name="plmnOctets", position=0, size=4, numSizePaddingBytes=0, numItems=3, numPaddingBytes=1},
                fields.uint8({name="item", position=0})
            ),
        })
end

return PLMNId_t
