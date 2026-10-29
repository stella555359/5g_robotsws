-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
