-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_common_NEIdentifier_t = require("xp/common/NEIdentifier_t")


function XpIntl_Get_ConnStatus_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_Get_ConnStatus_t", fieldName=fieldName, position=position, size=8}, {
            xp_common_NEIdentifier_t("neid", 0),
        })
end

return XpIntl_Get_ConnStatus_t
