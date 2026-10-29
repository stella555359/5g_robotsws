-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
