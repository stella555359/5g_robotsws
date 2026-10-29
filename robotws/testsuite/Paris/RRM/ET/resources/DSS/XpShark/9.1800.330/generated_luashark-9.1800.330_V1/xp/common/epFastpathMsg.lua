-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6
local fields = require("message")





-- payload of xpInterface:Fastpath
function epFastpathMsg (fieldName, position)
    return
        fields.DynamicEmbeddedProtocol({name="epFastpathMsg", fieldName=fieldName, position=position, size_unit=8, size=8},
            fields.uint32, fields.uint32, "xp_fastpath_xpfastpathmessage"
        )
end

return epFastpathMsg
