-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b
local fields = require("message")


function FailureDescription (fieldName, position)
    return
        fields.String({name="FailureDescription", fieldName=fieldName, position=position, size=256, capacity=255})
end

return FailureDescription
