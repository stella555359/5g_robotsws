-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6
local fields = require("message")





function Capabilities (fieldName, position)
    return
        fields.BitSet({name="Capabilities", fieldName=fieldName, position=position, size=32, padding=0},
            fields.byte({name="byte", position=position}))
end

return Capabilities
