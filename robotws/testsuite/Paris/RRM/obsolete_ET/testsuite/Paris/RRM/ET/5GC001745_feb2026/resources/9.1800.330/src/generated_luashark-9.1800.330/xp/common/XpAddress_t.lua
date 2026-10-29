-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_NEIdentifier_t = require("xp/common/NEIdentifier_t")
local xp_common_EndpointIdentifier_t = require("xp/common/EndpointIdentifier_t")


function XpAddress_t (fieldName, position)
    return
        fields.Structure({name="XpAddress_t", fieldName=fieldName, position=position, size=16}, {
            xp_common_NEIdentifier_t("neid", 0),
            xp_common_EndpointIdentifier_t("epid", 8),
        })
end

return XpAddress_t
