-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_CatmInfo = require("xp/dss/CatmInfo")
local xp_dss_messages_EnDssDlCellResourceAreaCoordinationReqExtension1Extensions = require("xp/dss/messages/EnDssDlCellResourceAreaCoordinationReqExtension1Extensions")


function EnDssDlCellResourceAreaCoordinationReqExtension1 (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellResourceAreaCoordinationReqExtension1", fieldName=fieldName, position=position, size=24}, {
            xp_dss_CatmInfo("catmInfo", 0),
            xp_dss_messages_EnDssDlCellResourceAreaCoordinationReqExtension1Extensions("extensions", 16),
        })
end

return EnDssDlCellResourceAreaCoordinationReqExtension1
