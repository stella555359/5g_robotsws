-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b
local fields = require("message")


-- payload of xpInterface:Internal
function epInternalMsg (fieldName, position)
    return
        fields.DynamicEmbeddedProtocol({name="epInternalMsg", fieldName=fieldName, position=position, size_unit=8, size=8},
            fields.uint32, fields.uint32, "xp_internal_xpinternalmessage"
        )
end

return epInternalMsg
