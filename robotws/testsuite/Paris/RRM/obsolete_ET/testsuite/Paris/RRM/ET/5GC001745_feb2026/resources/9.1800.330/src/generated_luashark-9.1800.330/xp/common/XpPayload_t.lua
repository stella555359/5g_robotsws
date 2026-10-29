-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_epXpControlMsg = require("xp/common/epXpControlMsg")
local xp_common_epDssMsg = require("xp/common/epDssMsg")
local xp_common_epInternalMsg = require("xp/common/epInternalMsg")
local xp_common_epBbpMsg = require("xp/common/epBbpMsg")


function XpPayload_t (fieldName, position)
    return
        fields.DynamicUnion({name="XpPayload_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            xp_common_epXpControlMsg("controlMsg", 0),
            xp_common_epDssMsg("dssMsg", 0),
            xp_common_epInternalMsg("internalMsg", 0),
            xp_common_epBbpMsg("bbpMsg", 0),
            },
            {0, 1, 2, 3, 4}
        )
end

return XpPayload_t
