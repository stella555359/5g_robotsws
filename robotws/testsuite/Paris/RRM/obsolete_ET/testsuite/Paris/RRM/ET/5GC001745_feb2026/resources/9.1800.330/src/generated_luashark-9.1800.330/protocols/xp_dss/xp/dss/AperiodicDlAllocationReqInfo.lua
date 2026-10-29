-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
