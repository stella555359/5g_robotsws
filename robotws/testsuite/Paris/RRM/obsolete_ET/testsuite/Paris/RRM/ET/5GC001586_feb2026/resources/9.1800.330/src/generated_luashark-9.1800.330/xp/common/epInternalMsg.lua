-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846
local fields = require("message")


-- payload of xpInterface:Internal
function epInternalMsg (fieldName, position)
    return
        fields.DynamicEmbeddedProtocol({name="epInternalMsg", fieldName=fieldName, position=position, size_unit=8, size=8},
            fields.uint32, fields.uint32, "xp_internal_xpinternalmessage"
        )
end

return epInternalMsg
