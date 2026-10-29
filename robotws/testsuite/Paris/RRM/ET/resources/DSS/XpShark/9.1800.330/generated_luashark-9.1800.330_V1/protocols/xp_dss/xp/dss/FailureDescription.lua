-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6
local fields = require("message")





function FailureDescription (fieldName, position)
    return
        fields.String({name="FailureDescription", fieldName=fieldName, position=position, size=256, capacity=255})
end

return FailureDescription
