-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")


function ActionItem (fieldName, position)
    return
        fields.Structure({name="ActionItem", fieldName=fieldName, position=position, size=8}, {
            fields.uint32({name="parameterName", position=0}),
            fields.uint32({name="parameterValue", position=4}),
        })
end

return ActionItem
