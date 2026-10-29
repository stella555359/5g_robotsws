-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_XpHeader_t = require("xp/common/XpHeader_t")
local xp_common_XpPayload_t = require("xp/common/XpPayload_t")
local xp_common_XpMessageExtensions = require("xp/common/XpMessageExtensions")


function XpMessage_t (fieldName, position)
    return
        fields.Structure({name="XpMessage_t", fieldName=fieldName, position=position, size=60}, {
            xp_common_XpHeader_t("XpHeader", 0),
            xp_common_XpPayload_t("XpPayload", 44),
            xp_common_XpMessageExtensions("extensions", 52),
        })
end

return XpMessage_t
