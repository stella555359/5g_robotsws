-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_AperiodicAllocationTime = require("xp/dss/AperiodicAllocationTime")
local xp_dss_AperiodicDlAllocationReqInfoExtensions = require("xp/dss/AperiodicDlAllocationReqInfoExtensions")


function AperiodicDlAllocationReqInfo (fieldName, position)
    return
        fields.Structure({name="AperiodicDlAllocationReqInfo", fieldName=fieldName, position=position, size=16}, {
            fields.uint8({name="priority", position=0}),
            fields.uint8({name="subframeShare", position=1}),
            fields.Padding({name="subframeShare_aperiodicAllocationTime_padding", position=2, size=2}),
            fields.enumeration(
                {name="aperiodicAllocationTime", position=4, enumTerm=xp_dss_AperiodicAllocationTime},
                ProtoField.int32, 4, "int32"),
            xp_dss_AperiodicDlAllocationReqInfoExtensions("extensions", 8),
        })
end

return AperiodicDlAllocationReqInfo
