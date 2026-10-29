-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_AperiodicDlAllocationReqInfo = require("xp/dss/AperiodicDlAllocationReqInfo")
local xp_dss_messages_EnDssAperiodicDlAllocationReqExtensions = require("xp/dss/messages/EnDssAperiodicDlAllocationReqExtensions")


-- Direction: CRM Client -> CRM.
--     This message is sent by a CRM Client to trigger an immediate allocation procedure to guarantee a resource share based on priority and not usual measured loads.
function EnDssAperiodicDlAllocationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssAperiodicDlAllocationReq_t", fieldName=fieldName, position=position, size=24}, {
            xp_dss_AperiodicDlAllocationReqInfo("aperiodicDlAllocationReqInfo", 0),
            xp_dss_messages_EnDssAperiodicDlAllocationReqExtensions("extensions", 16),
        })
end

return EnDssAperiodicDlAllocationReq_t
