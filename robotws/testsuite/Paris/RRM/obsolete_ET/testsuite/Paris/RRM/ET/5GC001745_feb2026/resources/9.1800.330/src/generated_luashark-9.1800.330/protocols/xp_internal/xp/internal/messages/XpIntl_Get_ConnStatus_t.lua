-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_NEIdentifier_t = require("xp/common/NEIdentifier_t")


function XpIntl_Get_ConnStatus_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_Get_ConnStatus_t", fieldName=fieldName, position=position, size=8}, {
            xp_common_NEIdentifier_t("neid", 0),
        })
end

return XpIntl_Get_ConnStatus_t
