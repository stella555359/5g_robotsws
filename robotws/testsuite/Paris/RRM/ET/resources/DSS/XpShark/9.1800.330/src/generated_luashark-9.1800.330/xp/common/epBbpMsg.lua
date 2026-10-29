-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6
local fields = require("message")


-- payload of xpInterface:Bbp
function epBbpMsg (fieldName, position)
    return
        fields.DynamicEmbeddedProtocol({name="epBbpMsg", fieldName=fieldName, position=position, size_unit=8, size=8},
            fields.uint32, fields.uint32, "xp_bbp_xpbbpmessage"
        )
end

return epBbpMsg
