-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
