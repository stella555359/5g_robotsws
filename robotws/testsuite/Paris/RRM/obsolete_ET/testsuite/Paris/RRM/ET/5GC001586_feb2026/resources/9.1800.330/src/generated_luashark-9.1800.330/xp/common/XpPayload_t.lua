-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_common_epXpControlMsg = require("xp/common/epXpControlMsg")
local xp_common_epDssMsg = require("xp/common/epDssMsg")
local xp_common_epInternalMsg = require("xp/common/epInternalMsg")


function XpPayload_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpPayload_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_common_epXpControlMsg("controlMsg", 0),
            xp_common_epDssMsg("dssMsg", 0),
            xp_common_epInternalMsg("internalMsg", 0),
            },
            {0, 1, 2, 3}
        )
end

return XpPayload_t
